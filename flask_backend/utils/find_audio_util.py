import os

def find_latest_audio_file(folder_path):
    latest_file_path = None
    latest_time = 0  # Keep track of the latest modification time

    for file_name in os.listdir(folder_path):
        if file_name.endswith(".wav"):
            file_path = os.path.join(folder_path, file_name)
            file_mod_time = os.path.getmtime(file_path)  # Get the file's last modification time
            
            # If this file is newer than the current latest, update
            if file_mod_time > latest_time:
                latest_time = file_mod_time
                latest_file_path = file_path

    return latest_file_path
