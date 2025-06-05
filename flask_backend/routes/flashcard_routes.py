from flask import Blueprint, request, jsonify
import json
from models.notes_model import Note, db
from functions.generate_flashcards_info import generate_flashcards

flashcard_bp = Blueprint('flashcard', __name__)



@flashcard_bp.route('/generate_flashcard', methods=['POST'])
def generate_flashcard():
    data = request.get_json()
    note_id = data.get('note_id')

    print(f"[DEBUG] Received request to generate flashcards for note_id: {note_id}")

    if not note_id:
        print("[ERROR] No note_id provided in request")
        return jsonify({"error": "Note ID is required"}), 400

    try:
        note = Note.query.get(note_id)
        if not note:
            print("[ERROR] Note not found")
            return jsonify({"error": "Note not found"}), 404

        note_text = note.content
        print(f"[DEBUG] Generating flashcards for note content length: {len(note_text)}")

        flashcards_data = generate_flashcards(note_text)
        print(f"[DEBUG] Flashcards generated successfully: {flashcards_data}")

        # Save flashcards to the database (as JSON string)
        note.flashcards = json.dumps(flashcards_data)
        db.session.commit()
        print("[DEBUG] Flashcards saved to the note successfully.")

        return jsonify(flashcards_data), 200

    except Exception as e:
        print(f"[ERROR] Exception during flashcard generation: {str(e)}")
        return jsonify({"error": "Internal server error", "details": str(e)}), 500

