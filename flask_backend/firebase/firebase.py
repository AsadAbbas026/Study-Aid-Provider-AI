import firebase_admin
from firebase_admin import credentials, db, storage
import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from config import Config

def initialize_firebase():
    """
    Function to initialize Firebase Admin SDK.
    """
    # Check if the app is already initialized
    if not firebase_admin._apps:
        # Initialize Firebase
        cred = credentials.Certificate(Config.FIREBASE_API_KEY)
        firebase_admin.initialize_app(cred, {
            'databaseURL': Config.DATABASE_URL  # Replace with actual
        })
    else:
        print("Firebase app already initialized.")

def get_user_data(email):
    """
    Function to get user UID and data by email from Firebase Realtime Database.
    """
    ref = db.reference("users")
    user_data = ref.order_by_child("email").equal_to(email).get()
    
    if user_data:
        user_id = list(user_data.keys())[0]         # ✅ Gets the UID
        user_info = user_data[user_id]              # ✅ Gets the user data
        return {'uid': user_id, 'data': user_info}  # Return both for flexibility

    return None

