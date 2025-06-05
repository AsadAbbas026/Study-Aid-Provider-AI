from flask import Blueprint, request, jsonify
from services.audioprocessing_services import process_and_transcribe_audio, translate_text_in_pipeline, post_process_transcription
from utils.find_audio_util import find_latest_audio_file
import os
import shutil
import uuid
import logging

audio_bp = Blueprint('audio_bp', __name__)
AUDIO_SOURCE_PATH = "temp"  # Directory to save temporary audio files
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@audio_bp.route('/get_audio', methods=['POST'])
def get_audio():
    audio_file = request.files.get('file')

    if not audio_file:
        return jsonify({'error': 'No audio file provided'}), 400
    
    try:
        temp_filename = f"{uuid.uuid4()}_{audio_file.filename}"
        temp_path = os.path.join(AUDIO_SOURCE_PATH, temp_filename)
        os.makedirs(AUDIO_SOURCE_PATH, exist_ok=True)
        audio_file.save(temp_path)
    except Exception as e:
        logger.error(f"Error saving audio file: {e}")
        return jsonify({'error': str(e)}), 500
    return jsonify({'message': 'File uploaded successfully', 'file_path': temp_path}), 200

@audio_bp.route('/upload_audio', methods=['POST'])
def upload_audio():
    audio_file = request.files.get('file')

    if not audio_file:
        return jsonify({'error': 'No audio file provided'}), 400
    
    try:
        temp_filename = f"{uuid.uuid4()}_{audio_file.filename}"
        temp_path = os.path.join("temp", temp_filename)
        os.makedirs("temp", exist_ok=True)
        audio_file.save(temp_path)
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    return jsonify({'message': 'File uploaded successfully', 'file_path': temp_path}), 200

@audio_bp.route('/transcribe', methods=['POST'])
def transcribe_audio():
    file = find_latest_audio_file(AUDIO_SOURCE_PATH)
    if not file:
        return jsonify({'error': 'No audio file found'}), 404
    
    try:
        transcribe_audio, translated_text = process_and_transcribe_audio(file, target_lang=None)
        shutil.rmtree(AUDIO_SOURCE_PATH, ignore_errors=True)  # Clean up temp directory
        return jsonify({
            'transcription': transcribe_audio,  # Only the raw transcription for the dashboard
            'translated_text': translated_text,
        }), 200
    except Exception as e:
        print(f"Error during transcription: {e}")
        return jsonify({'error': str(e)}), 500
