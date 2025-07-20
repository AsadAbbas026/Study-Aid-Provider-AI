import whisper
import os
import librosa
import multiprocessing
import psutil  # For system resource monitoring
import time  # For measuring execution time
from pydub import AudioSegment
from io import BytesIO
import numpy as np
import shutil
from .translation import translate_text
from concurrent.futures import ThreadPoolExecutor, as_completed

# Load Whisper model once globally
model = whisper.load_model("medium")

def convert_to_wav(input_file_path):
    """Converts input file to WAV format and returns the new file path."""
    file_name = os.path.splitext(os.path.basename(input_file_path))[0]
    output_file_path = os.path.join(os.path.dirname(input_file_path), file_name + ".wav")
    audio = AudioSegment.from_file(input_file_path)
    audio.export(output_file_path, format="wav")
    print(f"Audio file successfully converted to {output_file_path}")
    return output_file_path

def detect_language(file_path):
    """Detect language using Whisper without full transcription."""
    audio = whisper.load_audio(file_path)
    audio = whisper.pad_or_trim(audio)
    mel = whisper.log_mel_spectrogram(audio).to(model.device)
    _, probs = model.detect_language(mel)
    return max(probs, key=probs.get)

def transcribe_audio(file_path):
    """Transcribe once, after efficient language detection."""
    detected_lang = detect_language(file_path)
    print(f"[INFO] Detected language: {detected_lang}")

    # Define Indian languages to override
    indian_languages = ['hi', 'ta', 'te', 'bn', 'ml', 'kn', 'gu', 'mr', 'pa', 'or', 'as']

    # Override to Urdu if needed
    if detected_lang in indian_languages:
        print(f"[INFO] Language '{detected_lang}' is in Indian list. Using Urdu (ur) for transcription.")
        detected_lang = 'ur'

    # Transcribe only once with the selected language
    result = model.transcribe(file_path, language=detected_lang, task="transcribe", verbose=True)

    return result['text'], detected_lang

def get_dynamic_chunk_size(duration):
    """Determines chunk size dynamically based on duration."""
    if duration <= 600:  
        return 30, 3  # 30s chunks, 3s overlap
    elif duration <= 1200:  
        return 60, 5
    elif duration <= 3000:  
        return 120, 7
    else:  
        return 300, 10  

def get_optimal_num_workers():
    """Decides number of worker processes based on system resources."""
    num_cores = multiprocessing.cpu_count()
    available_memory = psutil.virtual_memory().available / (1024 ** 3)

    if num_cores <= 4 or available_memory < 4:
        return 2  
    elif num_cores <= 8 or available_memory < 8:
        return 4  
    else:
        return 6  

def get_audio_duration(file_path):
    """Returns the duration of an audio file in seconds."""
    return librosa.get_duration(path=file_path)

def chunk_audio_dynamic(file_path):
    """Chunks the audio dynamically and further splits long segments."""
    filepath = convert_to_wav(file_path)  
    audio, sr = librosa.load(filepath, sr=None)  
    duration = librosa.get_duration(y=audio, sr=sr)  

    chunk_length, overlap = get_dynamic_chunk_size(duration)
    
    chunk_length_samples = chunk_length * sr  # Convert to samples
    overlap_samples = overlap * sr

    main_chunk_dir = "audio_chunks"
    os.makedirs(main_chunk_dir, exist_ok=True)

    sub_chunk_dir = "audio_sub_chunks"
    os.makedirs(sub_chunk_dir, exist_ok=True)

    sub_chunks = []
    start_sample = 0
    i = 0

    while start_sample < len(audio):
        end_sample = start_sample + chunk_length_samples
        chunk_audio = audio[start_sample:end_sample]

        # Convert to 16-bit PCM
        chunk = np.array(chunk_audio * 32767, dtype=np.int16)
        byte_io = BytesIO()

        # Create raw audio segment
        raw_audio = AudioSegment.from_raw(
            BytesIO(chunk.tobytes()),
            sample_width=2,
            frame_rate=sr,
            channels=1
        )
        raw_audio.export(byte_io, format="wav")
        byte_io.seek(0)

        chunk_filename = os.path.join(main_chunk_dir, f"chunk_{i}.wav")
        with open(chunk_filename, "wb") as f:
            f.write(byte_io.read())
        print(f"Saved main chunk {i}: {chunk_filename}")

        # Further divide into sub-chunks if longer than 60 seconds
        chunk_duration = librosa.get_duration(y=chunk_audio, sr=sr)
        if chunk_duration > 60:
            sub_chunk_length_samples = 30 * sr  # 30s per sub-chunk
            j = 0
            for sub_start in range(0, len(chunk_audio), sub_chunk_length_samples):
                sub_end = sub_start + sub_chunk_length_samples
                sub_chunk_audio = chunk_audio[sub_start:sub_end]

                sub_chunk = np.array(sub_chunk_audio * 32767, dtype=np.int16)
                byte_io = BytesIO()

                # Create raw audio segment
                raw_sub_chunk = AudioSegment.from_raw(
                    BytesIO(sub_chunk.tobytes()),
                    sample_width=2,
                    frame_rate=sr,
                    channels=1
                )
                raw_sub_chunk.export(byte_io, format="wav")
                byte_io.seek(0)

                sub_chunk_filename = os.path.join(sub_chunk_dir, f"sub_chunk_{i}_{j}.wav")
                with open(sub_chunk_filename, "wb") as f:
                    f.write(byte_io.read())
                sub_chunks.append((i, j, sub_chunk_filename))
                print(f"Saved sub-chunk {i}-{j}: {sub_chunk_filename}")
                j += 1
        else:
            sub_chunks.append((i, 0, chunk_filename))

        start_sample = end_sample - overlap_samples  # Adjust to prevent infinite loop
        i += 1

    print(f"Total Sub-Chunks Created: {len(sub_chunks)}")
    return sub_chunks

def transcribe_single_chunk(index, sub_index, chunk, lang_code):
    """Transcribes a single chunk."""
    print(f"Transcribing chunk {index}-{sub_index}...")
    transcription = transcribe_audio(chunk)
    return (index, sub_index, transcription)

def transcribe_audio_chunks_parallel(sub_chunks, lang_code):
    num_workers = get_optimal_num_workers()
    print(f"Using {num_workers} threads for parallel transcription...")

    results = []

    with ThreadPoolExecutor(max_workers=num_workers) as executor:
        futures = {
            executor.submit(transcribe_single_chunk, i, j, chunk, lang_code): (i, j)
            for i, j, chunk in sub_chunks
        }

        for future in as_completed(futures):
            try:
                result = future.result()
                results.append(result)
            except Exception as e:
                i, j = futures[future]
                print(f"Failed to transcribe chunk {i}-{j}: {e}")

    results.sort(key=lambda x: (x[0], x[1]))
    return " ".join([text for _, _, text in results])


def save_transcription_to_file(transcription, file_name="transcription.txt"):
    """Saves the transcription to a text file."""
    with open(file_name, "w", encoding="utf-8") as f:
        f.write(transcription)
    print(f"Transcription saved to {file_name}")

def execute_transcription(filepath, lang_code):
    """Executes the full transcription pipeline."""
    start_time = time.time()
    
    duration = get_audio_duration(filepath)  # Store duration once

    if duration > 10200:
        print("Audio file exceeds 3-hour limit. Please provide a shorter file.")
        return
    
    if duration < 60:
        print("Audio file is less than 1 minute. Please provide a longer file.")
        try:
            result, language = transcribe_audio(filepath)
            print("\nTranscription:\n", result)
            print(f"\nLanguage: {language}")
            save_transcription_to_file(result)
            return result, language
        except Exception as e:
            print(f"Error during transcription: {e}")
        return

    print("Processing audio file...")

    # Step 1: Chunk the audio
    sub_chunks = chunk_audio_dynamic(filepath)

    # Step 2: Transcribe chunks in parallel
    final_transcription = transcribe_audio_chunks_parallel(sub_chunks, lang_code)
    print("\nFinal Transcription:\n", final_transcription)

    # Step 3: Save the transcription
    save_transcription_to_file(final_transcription)

    try:
        if language != "en":

            print("Translating transcription...")
            translated_text = translate_text(final_transcription, "en")  # Change "urdu" to target language
            save_transcription_to_file(translated_text, file_name="translated_transcription.txt")
            print("Translation saved to translated_transcription.txt")
    except Exception as e:
        print(f"Translation failed: {e}")
    execution_time = time.time() - start_time
    print(f"\nTotal Execution Time: {execution_time:.2f} seconds")
    shutil.rmtree("audio_chunks", ignore_errors=True)  # Clean up main chunks
    shutil.rmtree("audio_sub_chunks", ignore_errors=True)  # Clean up sub chunks
    print("Temporary files cleaned up.")
    print("Time Taken for transcription: {:.2f} seconds".format(execution_time))

    return final_transcription, translated_text

"""
if __name__ == "__main__":
    filepath="C:\\Users\\ALRASHIDS\\Desktop\\New folder (8)\\flask_backend\\normalized_output.wav"
    execute_transcription(filepath, lang_code=None)
"""