from flask import Blueprint, request, jsonify
from models.notes_model import Note
from models.summary_model import Summary
from services.summary_services import generate_summary_from_notes
from models.extensions import db

summary_bp = Blueprint('summary', __name__)

@summary_bp.route('/generate_summary', methods=['POST'])
def generate_summary():
    """
    Endpoint to generate and store a summary for a given note.
    """
    try:
        data = request.get_json()
        print(f"[DEBUG] Received data: {data}")

        user_id = data.get('user_id')
        note_id = data.get('note_id')

        if not user_id or not note_id:
            print("[DEBUG] Missing user_id or note_id")
            return jsonify({'message': 'User ID and Note ID are required'}), 400

        # Fetch note from DB
        note = Note.query.filter_by(id=note_id, user_id=user_id).first()
        if not note:
            print(f"[DEBUG] No note found for user_id={user_id} and note_id={note_id}")
            return jsonify({'message': 'Note not found for the user'}), 404

        print(f"[DEBUG] Note content: {note.content[:100]}...")  # Print only first 100 chars

        # Generate summary using LLM chain
        summary_text = generate_summary_from_notes(note.content)
        print(f"[DEBUG] Generated summary: {summary_text}")

        # Save to DB
        summary = Summary(user_id=user_id, note_id=note_id, summary_text=summary_text)
        db.session.add(summary) 
        db.session.commit()
        print(f"[DEBUG] Summary saved to DB for user_id={user_id}, note_id={note_id}")

        return jsonify({'message': 'Summary generated successfully', 'summary': summary_text}), 200

    except Exception as e:
        print(f"[ERROR] Exception occurred: {str(e)}")
        return jsonify({'message': 'Error generating summary', 'error': str(e)}), 500

@summary_bp.route('/get_summaries', methods=['POST'])
def get_all_summaries():
    """
    Endpoint to retrieve all summaries for a given user.
    Includes related note title and content.
    """
    try:
        data = request.get_json()
        print(f"[DEBUG] Received data: {data}")

        user_id = data.get('user_id')

        if not user_id:
            print("[DEBUG] Missing user_id")
            return jsonify({'message': 'User ID is required'}), 400

        # Fetch summaries and their related notes for the user
        summaries = Summary.query.filter_by(user_id=user_id).all()
        print(f"[DEBUG] Found {len(summaries)} summaries for user_id={user_id}")

        summaries_data = []
        for summary in summaries:
            summaries_data.append({
                'id': summary.id,
                'note_id': summary.note_id,
                'summary_text': summary.summary_text,
                'title': summary.note.title if summary.note else "Untitled",
                'description': summary.note.content if summary.note else "No Description"
            })

        return jsonify({'summaries': summaries_data}), 200  

    except Exception as e:
        print(f"[ERROR] Exception occurred: {str(e)}")
        return jsonify({'message': 'Error retrieving summaries', 'error': str(e)}), 500
    
@summary_bp.route('/delete_summary', methods=['POST'])
def delete_summary():
    """
    Endpoint to delete a summary for a given user and note.
    """
    try:
        data = request.get_json()
        print(f"[DEBUG] Received data: {data}")
        user_id = data.get('user_id')
        summary_id = data.get('summary_id')

        if not summary_id or not user_id:
            print("[DEBUG] Missing summary_id or user_id")
            return jsonify({'message': 'Summary ID and User ID is required'}), 400

        # Fetch summary from DB
        summary = Summary.query.filter_by(id=summary_id, user_id = user_id).first()
        if not summary:
            print(f"[DEBUG] No summary found for summary_id={summary_id}")
            return jsonify({'message': 'Summary not found for the user'}), 404

        # Delete summary from DB    
        db.session.delete(summary)
        db.session.commit()
        print(f"[DEBUG] Summary deleted from DB for summary_id={summary_id}")

        return jsonify({'message': 'Summary deleted successfully'}), 200

    except Exception as e:
        print(f"[ERROR] Exception occurred: {str(e)}")
        return jsonify({'message': 'Error deleting summary', 'error': str(e)}), 500