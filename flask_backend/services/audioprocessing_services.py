import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from functions.postprocess_transcription import post_process_transcriptions
from functions.preprocess_audio import execute_audio_pipeline
from functions.transcription import execute_transcription
from functions.translation import translate_text as perform_translation

def process_and_transcribe_audio(input_audio_file, target_lang):
    # Step 1: Preprocess audio
    preprocessed_audio = execute_audio_pipeline(input_audio_file)

    # Step 2: Transcribe the audio
    transcribed_text, translated_text = execute_transcription(preprocessed_audio, target_lang)
    
    return transcribed_text, translated_text

def post_process_transcription(transcribed_text):
    # Step 3: Post-process the transcription
    notes, tags, topics = post_process_transcriptions(transcribed_text)
    
    return notes, tags, topics

def translate_text_in_pipeline(text_to_translate, target_lang):
    # Step 4: Translate the text using renamed function
    translated_text = perform_translation(text_to_translate, target_lang)
    
    return translated_text

