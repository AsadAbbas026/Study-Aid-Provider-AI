from pydub import AudioSegment
import librosa
import numpy as np
import soundfile as sf
from silero_vad import get_speech_timestamps
import torch
import pyloudnorm as pyln
import noisereduce as nr
from pyannote.audio import Pipeline
import torch
import time

def convert_to_wav(filename, output_name):
    audio = AudioSegment.from_file(filename)
    audio.export(output_name, format="wav")

def scale_amplitude(input_file, output_file, max_scale_factor=1000.0, target_peak=1.0):
    audio, sr = librosa.load(input_file, sr=None)
    peak_amplitude = np.max(np.abs(audio))
    print(f"Peak amplitude: {peak_amplitude:.2f}")
    if peak_amplitude > 0:
        scale_factor = min(max_scale_factor, target_peak / peak_amplitude)
    else:
        scale_factor = max_scale_factor  # Default if peak is zero

    audio_scaled = audio * scale_factor

    audio_final = np.clip(audio_scaled, -1, 1)
    sf.write(output_file, audio_final, sr)
    print(f"Audio amplified by a factor of {scale_factor:.2f} and saved as: {output_file}")

def hybrid_vad(input_file, output_file, energy_threshold=0.001):
    # Load audio
    audio, sr = librosa.load(input_file, sr=16000)

    # Load the Silero VAD model
    vad_model, vad_utils = torch.hub.load(repo_or_dir='snakers4/silero-vad', model='silero_vad', trust_repo=True)

    # Correct way to extract the function
    get_speech_timestamps = vad_utils[0]  # The first item in the tuple is 'get_speech_timestamps'

    # Convert audio to tensor and run VAD
    speech_timestamps = get_speech_timestamps(torch.tensor(audio, dtype=torch.float32), vad_model, sampling_rate=sr)

    # Extract speech segments
    silero_speech_audio = np.concatenate([audio[seg['start']:seg['end']] for seg in speech_timestamps])

    frame_length = 512
    energy = np.array([sum(abs(silero_speech_audio[i:i+frame_length])**2) for i in range(0, len(silero_speech_audio), frame_length)])

    speech_indices = np.where(energy > energy_threshold)[0]
    final_speech_audio = np.concatenate([silero_speech_audio[i*frame_length:(i+1)*frame_length] for i in speech_indices])

    sf.write(output_file, final_speech_audio, sr)
    print(f"Hybrid VAD processed audio saved as: {output_file}")

def normalize_loudness(input_file, output_file, target_lufs=-15.0):
    # Load audio
    audio, sr = librosa.load(input_file, sr=16000)

    meter = pyln.Meter(sr)  # Create a meter instance
    loudness = meter.integrated_loudness(audio)

    normalized_audio = pyln.normalize.loudness(audio, loudness, target_lufs)

    normalized_audio = np.clip(normalized_audio, -1.0, 1.0)

    sf.write(output_file, normalized_audio, sr)
    print(f"Normalized audio saved as: {output_file}")

def normalize_audio(input_file, output_file):
    audio, sr = librosa.load(input_file, sr=None)
    peak_amplitude = np.max(np.abs(audio))
    
    if peak_amplitude > 0:
        audio_normalized = audio / peak_amplitude  # Normalize to 1.0
        # audio_normalized = audio * 1000  # Increase volume
    else:
        audio_normalized = audio  # Keep as is if silent
    
    sf.write(output_file, audio_normalized, sr)
    print(f"Audio normalized and saved as: {output_file}")

def reduce_noise(input_file, output_file):
    # Load audio
    audio, sr = librosa.load(input_file, sr=None)

    # Apply noise reduction
    reduced_audio = nr.reduce_noise(y=audio, sr=sr, stationary=False)

    # Save the denoised file
    sf.write(output_file, reduced_audio, sr)
    print(f"Denoised audio saved as: {output_file}")

def spectral_subtract(input_file, output_file, noise_frames=20, alpha=2.0, beta=0.002):
    audio, sr = librosa.load(input_file, sr=None)
    stft = librosa.stft(audio, n_fft=2048, hop_length=512)
    noise_est = np.mean(np.abs(stft[:, :noise_frames]), axis=1, keepdims=True)
    clean_stft = np.maximum(np.abs(stft) - alpha * noise_est, beta) * np.exp(1j * np.angle(stft))
    cleaned_audio = librosa.istft(clean_stft, hop_length=512)

    sf.write(output_file, cleaned_audio, sr)
    print(f"Spectral subtraction processed audio saved as: {output_file}")
"""
def perform_speaker_diarization(audio_file, segmentation_threshold=0.65, clustering_threshold=0.75):
    
    Perform speaker diarization on an audio file and save separated speaker audio.
    
    Parameters:
    - audio_file (str): Path to the input audio file.
    - hf_auth_token (str): Hugging Face authentication token.
    - segmentation_threshold (float): Threshold for segmentation.
    - clustering_threshold (float): Threshold for clustering speakers.
    

    hf_auth_token = os.getenv("HF_AUTH_TOKEN")
    # Load Speaker Diarization Model
    diarization_pipeline = Pipeline.from_pretrained("pyannote/speaker-diarization", use_auth_token=hf_auth_token)
    
    # Configure diarization parameters
    diarization_pipeline = diarization_pipeline.instantiate({
        "segmentation": {"threshold": segmentation_threshold, "min_duration_off": 0.1},
        "clustering": {"threshold": clustering_threshold}
    })
    
    # Load audio file
    waveform, sample_rate = torchaudio.load(audio_file)
    
    # Convert waveform to mono if stereo
    if waveform.shape[0] > 1:
        waveform = torch.mean(waveform, dim=0, keepdim=True)
    
    # Apply Speaker Diarization
    diarization_result = diarization_pipeline(audio_file)
    
    # Convert waveform to numpy for easier processing
    waveform_np = waveform.numpy().flatten()
    
    # Create dictionary to store speaker audio segments
    speaker_audio = {}
    
    # Iterate over diarization results
    for turn, _, speaker in diarization_result.itertracks(yield_label=True):
        start_sample = int(turn.start * sample_rate)
        end_sample = int(turn.end * sample_rate)
    
        if speaker not in speaker_audio:
            speaker_audio[speaker] = []
    
        speaker_audio[speaker].append(waveform_np[start_sample:end_sample])
    
    # Save separate audio files for each speaker
    for speaker, chunks in speaker_audio.items():
        speaker_wav = np.concatenate(chunks)  # Concatenate all segments for each speaker
        speaker_torch = torch.tensor(speaker_wav).unsqueeze(0)  # Convert back to torch tensor
    
        # Save as WAV
        output_file = f"{audio_file.rsplit('.', 1)[0]}_{speaker}.wav"
        torchaudio.save(output_file, speaker_torch, sample_rate)
        print(f"Saved {output_file}")
"""

def execute_audio_pipeline(filename):
    start_time = time.time()
    output_name = "output.wav"
    convert_to_wav(filename, output_name)

    output_file = "scaled_audio.wav"
    scale_amplitude(output_name, output_file, max_scale_factor=15.0)  # Increase loudness

    hybrid_vad(output_file, "cleaned_output.wav")

    normalize_audio("cleaned_output.wav", "normalized_output.wav")
    normalized_file = "normalized_outputs.wav"
    normalize_loudness("normalized_output.wav", normalized_file)

    denoised_file = "denoised.wav"
    reduce_noise(normalized_file, denoised_file)

    spectral_subtracted_file = "SS_output.wav"
    spectral_subtract(denoised_file, spectral_subtracted_file)

    # Run Speaker Diarization on the cleaned audio
    #perform_speaker_diarization(spectral_subtracted_file)
    end_time = time.time()
    print(f"Total time taken: {end_time - start_time} seconds")
    
    
    return normalized_file
