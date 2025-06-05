from flask import Blueprint, request, jsonify, session
from models.notes_model import Note
from models.extensions import db
from firebase.firebase import get_user_data
from services.audioprocessing_services import post_process_transcription
from datetime import datetime
from utils.global_store import transcription_data, userID
import requests

note_bp = Blueprint('notes', __name__)

# Create a Note
@note_bp.route('/add_note', methods=['POST'])
def add_manual_note():
    data = request.get_json()

    user_id = data.get('user_id')
    title = data.get('title')
    content = data.get('desc')
    note_type = data.get('type', 'Manual')

    print(f"[DEBUG] Creating note: user_id={user_id}, title={title}, type={note_type}, content={content}")

    if not user_id or not title or not content:
        print("[ERROR] Missing fields in request")
        return jsonify({'message': 'User ID, title, and content are required!'}), 400

    try:
        new_note = Note(
            user_id=user_id,
            title=title,
            content=content,
            type=note_type
        )
        db.session.add(new_note)
        db.session.commit()

        print(f"[SUCCESS] Note created with ID: {new_note.id}")
        return jsonify({'message': 'Note created successfully!', 'note_id': new_note.id}), 201

    except Exception as e:
        print(f"[ERROR] Failed to add note: {str(e)}")
        return jsonify({'error': str(e)}), 500

# Edit a Note
@note_bp.route('/update_note', methods=['PUT'])
def update_note():
    data = request.get_json()
    print("[DEBUG] Raw request data:", data)

    # Ensure we're getting the expected fields
    if not data:
        print("[ERROR] No JSON data received")
        return jsonify({'message': 'No data received'}), 400
        
    note_id = data.get('id')  # Changed from 'id' to match Flutter
    user_id = data.get('user_id')
    
    print(f"[DEBUG] Looking for note_id: {note_id}, user_id: {user_id}")
    title = data.get('title')
    content = data.get('content')

    print(f"[DEBUG] Extracted fields - ID: {note_id}, User ID: {user_id}, Title: {title}, Content: {content}")

    if not note_id or not user_id:
        print("[ERROR] Missing note_id or user_id in request")
        return jsonify({'message': 'Note ID and User ID are required!'}), 400

    note = Note.query.filter_by(id=note_id, user_id=user_id).first()

    if not note:
        print(f"[ERROR] No note found with ID {note_id} for user {user_id}")
        return jsonify({'message': 'Note not found or access denied!'}), 404

    if title:
        print(f"[INFO] Updating title from '{note.title}' to '{title}'")
        note.title = title
    if content:
        print(f"[INFO] Updating content for note ID {note_id}")
        note.content = content

    try:
        db.session.commit()
        print(f"[SUCCESS] Note {note_id} updated successfully for user {user_id}")
        return jsonify({'message': 'Note updated successfully!'}), 200
    except Exception as e:
        db.session.rollback()
        print(f"[ERROR] Failed to update note: {str(e)}")
        return jsonify({'error': str(e)}), 500

# Delete a Note
@note_bp.route('/delete_note', methods=['DELETE'])
def delete_note():
    data = request.get_json()
    print(f"[DEBUG] Received data for deletion: {data}")  # Debugging incoming request data

    note_id = data.get('id')
    user_id = data.get('user_id')

    if not note_id or not user_id:
        print("[DEBUG] Missing note_id or user_id in request.")
        return jsonify({'message': 'Note ID and User ID are required!'}), 400

    print(f"[DEBUG] Attempting to delete Note ID: {note_id} for User ID: {user_id}")
    note = Note.query.filter_by(id=note_id, user_id=user_id).first()

    if not note:
        print(f"[DEBUG] No note found with ID: {note_id} for User ID: {user_id}")
        return jsonify({'message': 'Note not found!'}), 404

    print(f"[DEBUG] Deleting note: {note}")
    db.session.delete(note)
    db.session.commit()
    print(f"[DEBUG] Note deleted successfully!")

    return jsonify({'message': 'Note deleted successfully!'}), 200

# Search Notes by Title or Content
@note_bp.route('/search', methods=['POST'])
def search_notes():
    data = request.get_json()
    user_id = data.get('user_id')
    query = data.get('query')

    print("🔍 [DEBUG] /search endpoint called")
    print(f"📥 [DEBUG] Received user_id: {user_id}")
    print(f"📥 [DEBUG] Received query: '{query}'")

    if not query:
        print("❌ [DEBUG] Missing search query")
        return jsonify({'message': 'Search query is required!'}), 400

    if not user_id:
        print("❌ [DEBUG] Missing user_id")
        return jsonify({'message': 'User ID is required!'}), 400

    try:
        # Search for notes by title, do not query content
        results = Note.query.filter_by(user_id=user_id).filter(
            Note.title.ilike(f'%{query}%')  # Only search by title
        ).all()

        print(f"✅ [DEBUG] Found {len(results)} matching notes")

        # Debugging to inspect the results before returning
        for note in results:
            print(f"🧾 [DEBUG] Note Title: {note.title}, Content: {note.content}, Created At: {note.created_at}")

        # Prepare the notes to be returned
        notes = [{'id': note.id, 'title': note.title, 'content': note.content, 'createdAt': note.created_at} for note in results]

        print(f"📦 [DEBUG] Returning {len(notes)} notes in response")

        return jsonify({'notes': notes}), 200

    except Exception as e:
        print(f"🔥 [ERROR] Exception occurred during search: {e}")
        return jsonify({'message': 'An error occurred during search!'}), 500

# Filter Notes by Date Range
@note_bp.route('/filter', methods=['POST'])
def filter_notes():

    data = request.get_json()
    user_id = data.get('user_id')
    start_date = data.get('start_date')
    end_date = data.get('end_date')
    note_type = data.get('note_type')  # Optional

    if not user_id or not start_date or not end_date:
        return jsonify({'message': 'User ID, start date, and end date are required!'}), 400

    try:
        start_date = datetime.strptime(start_date, '%Y-%m-%d')
        end_date = datetime.strptime(end_date, '%Y-%m-%d')
    except ValueError:
        return jsonify({'message': 'Invalid date format! Use YYYY-MM-DD'}), 400

    query = Note.query.filter(
        Note.user_id == user_id,
        Note.created_at.between(start_date, end_date)
    )

    if note_type:
        query = query.filter_by(type=note_type)

    notes = query.all()
    serialized_notes = [{'id': n.id, 'title': n.title, 'content': n.content} for n in notes]

    return jsonify({'notes': serialized_notes}), 200


@note_bp.route('/transcription', methods=['POST'])
def get_transcription_data():
    global transcription_data, userID
    data = request.get_json()
    userID = data.get('user_id')
    transcription_data = data.get('text')

    if not userID:
        return jsonify({'error': 'User ID is required!'}), 400
    if not transcription_data:
        return jsonify({'error': 'No transcription data provided'}), 400
    try:
        session['user_id'] = userID
        session['transcription_data'] = transcription_data
        print("Transcription: " + transcription_data)
        print("\nUser ID: " + userID)
        return jsonify({'message': 'Transcription data received successfully!'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
@note_bp.route('/create_transcribed_note', methods=['GET'])
def note_creation():
    global transcription_data, userID

    print("---- /create_transcribed_note endpoint hit ----")
    print(f"Transcription data present? {'Yes' if transcription_data else 'No'}")
    print(f"userID: {userID if userID else 'None'}")

    if not transcription_data:
        print("No transcription data found. Aborting note creation.")
        return jsonify({'message': 'No transcription data available!'}), 400

    try:
        print("Starting transcription post-processing...")

        notes, tags, title = post_process_transcription(transcription_data)

        print("Post-processing completed.")
        print(f"Extracted title: {title}")
        print(f"Extracted tags (raw): {tags}")
        print(f"Extracted notes length: {len(notes)}")

        # Sanitize and join tags
        tags = [str(tag).strip() for tag in tags if tag]
        tags_str = ','.join(tags) if tags else None
        print(f"Sanitized tags list: {tags}")
        print(f"Tags string for DB: {tags_str}")

        print("Creating new Note instance...")
        new_note = Note(
            user_id=userID,
            title=title,
            content=notes,
            tags=tags_str,
            type='Transcribed'
        )
        print("New Note object created:")
        print(f" - Title: {new_note.title}")
        print(f" - Content preview: {new_note.content[:100]}...")  # Show only first 100 characters
        print(f" - Tags: {new_note.tags}")
        print(f" - Type: {new_note.type}")

        db.session.add(new_note)
        print("Note added to DB session.")

        # Extra debugging info before committing
        print(f"Title length: {len(title)}")
        print(f"Tags length: {len(tags_str) if tags_str else 0}")
        print(f"Content length: {len(notes)}")

        db.session.commit()
        print("DB session committed successfully.")

        return jsonify({'message': 'Transcribed note created!', 'note_id': new_note.id}), 201

    except Exception as e:
        print(f"Error occurred while creating note: {e}")
        return jsonify({'error': str(e)}), 500

@note_bp.route('/get_notes', methods=['POST'])
def get_all_notes():
    data = request.get_json()
    user_id = data.get('user_id')
    print(f"[DEBUG] Received request for notes with user_id: {user_id}")

    if not user_id:
        print("[ERROR] No user_id provided in request")
        return jsonify({"error": "User ID is required"}), 400

    try:
        notes = Note.query.filter_by(user_id=user_id).order_by(Note.created_at.desc()).all()
        print(f"[DEBUG] Retrieved {len(notes)} notes for user_id: {user_id}")

        notes_list = []
        for note in notes:
            print(f"[DEBUG] Note ID: {note.id}, Title: {note.title}, Created At: {note.created_at}")
            notes_list.append({
                'note_id': note.id,
                'title': note.title,
                'desc': note.content,
                'createdAt': note.created_at.strftime('%d/%m/%Y %H:%M'),
                'type': note.type
            })

        return jsonify({"notes": notes_list}), 200

    except Exception as e:
        print(f"[ERROR] Failed to fetch notes: {str(e)}")
        return jsonify({"error": str(e)}), 500
        
@note_bp.route('/share_note_to_rtdb', methods=['POST'])
def share_note_to_rtdb():
    try:
        data = request.json
        note_id = data.get("note_id")
        sender_user_id = data.get("sender_user_id")

        # Fetch note from MySQL
        note = Note.query.filter_by(id=note_id, user_id=sender_user_id).first()
        if not note:
            return jsonify({"error": "Note not found"}), 404

        # Prepare note data with 'shared' flag
        note_data = {
            "title": note.title,
            "content": note.content,
            "type": note.type,
            "sender_user_id": sender_user_id,
            "shared": True  # Set the shared flag to allow Firebase rules to accept the write
        }

        # Construct the Firebase path to the note's location
        firebase_url = f"https://study-buddy-system-default-rtdb.firebaseio.com/notes/{sender_user_id}.json"
        
        # Push to Firebase RTDB
        res = requests.put(firebase_url, json=note_data)  # Use PUT since we're writing to a specific path
        if res.status_code != 200:
            print(f"Error uploading to Firebase: {res.status_code} - {res.text}")
            return jsonify({"error": "Failed to upload to Firebase"}), 500

        return jsonify({"firebase_key": firebase_url}), 200  # Return the note_id as the firebase key

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
    except Exception as e:
        print(f"Error: {str(e)}")  # Catch any other errors
        return jsonify({"error": str(e)}), 500

@note_bp.route('/import_shared_note', methods=['POST'])
def import_shared_note():
    data = request.json
    firebase_key = data.get("firebase_key")  # This is the FULL URL from the previous route
    receiver_user_id = data.get("receiver_user_id")

    if not firebase_key or not receiver_user_id:
        return jsonify({"error": "Missing fields"}), 400

    # Use the received firebase_key directly (since it's the full URL)
    res = requests.get(firebase_key)
    if res.status_code != 200:
        return jsonify({"error": "Failed to fetch from Firebase"}), 500

    note_data = res.json()
    if not note_data:
        return jsonify({"error": "Note not found"}), 404

    # Save to MySQL
    new_note = Note(
        user_id=receiver_user_id,
        title=note_data.get("title"),
        content=note_data.get("content"),
        type="Shared"
    )
    db.session.add(new_note)
    db.session.commit()

    # Delete from Firebase using the same URL
    try:
        del_res = requests.delete(firebase_key)
        del_res.raise_for_status()
    except requests.exceptions.RequestException as e:
        print("Firebase deletion failed:", str(e))
        return jsonify({"warning": "Note imported but not deleted from Firebase"}), 202


    return jsonify({"message": "Note shared successfully"}), 200
