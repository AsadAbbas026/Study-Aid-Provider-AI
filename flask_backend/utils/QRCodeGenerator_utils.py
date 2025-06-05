import requests
import qrcode
import json

def save_note_and_generate_qr(firebase_url, user_id, note_id, note_data, qr_filename="shared_note_qr.png"):
    """
    Saves a note to Firebase Realtime Database and generates a QR code with the direct URL.

    Args:
        firebase_url (str): Base URL of the Firebase Realtime Database.
        user_id (str): ID of the user saving the note.
        note_id (str): Unique ID for the note.
        note_data (dict): Dictionary containing the note content.
        qr_filename (str): Filename for the generated QR image.

    Returns:
        dict: Contains 'success' (bool), 'url' (str), and 'message' (str).
    """
    try:
        path = f"/notes/{user_id}/{note_id}.json"
        full_url = f"{firebase_url}{path}"

        response = requests.put(full_url, json=note_data)
        if response.status_code == 200:
            # Generate QR Code
            qr = qrcode.make(full_url)
            qr.save(qr_filename)

            return {
                "success": True,
                "url": full_url,
                "message": f"Note saved successfully! QR Code saved as {qr_filename}."
            }
        else:
            return {
                "success": False,
                "url": full_url,
                "message": f"Failed to save note. Firebase responded with: {response.text}"
            }

    except Exception as e:
        return {
            "success": False,
            "url": None,
            "message": f"Error: {str(e)}"
        }

# Example usage
if __name__ == "__main__":
    firebase_url = "https://study-buddy-system-default-rtdb.firebaseio.com"
    user_id = "user123"
    note_id = "note456"
    note_data = {
        "title": "LangChain Tips",
        "content": "Use prompt chaining, templates, and parsers for structure.",
        "shared": True
    }

    result = save_note_and_generate_qr(firebase_url, user_id, note_id, note_data)
    print(result["message"])
    if result["success"]:
        print("Note URL:", result["url"])
