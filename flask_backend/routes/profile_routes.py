from flask import Blueprint, request, jsonify
from firebase.firebase import db, storage
from utils.hash_utils import hash_password, verify_password
import uuid

profile_bp = Blueprint('profile', __name__)

@profile_bp.route('/get_profile/<uid>', methods=['GET'])
def get_profile(uid):
    try:
        # Fetch user data from Firebase Realtime Database
        ref = db.reference(f'users/{uid}')
        user_data = ref.get()

        if not user_data:
            return jsonify({'success': False, 'message': 'User not found'}), 404

        # Assuming 'email' exists in the user_data from RTDB
        user_profile = {
            'uid': uid,
            'fullName': user_data.get('username'),
            'email': user_data.get('email'),  # Check if this key exists correctly
            'phone': user_data.get('phone'),
            'university': user_data.get('university'),
            'profile_image_base64': user_data.get('profile_image_base64'),  # Assuming this is the key for the image
        }

        return jsonify({'success': True, 'profile': user_profile})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500
    
@profile_bp.route('/update_account/<uid>', methods=['POST'])
def update_account(uid):
    try:
        data = request.get_json()
        ref = db.reference(f'users/{uid}')
        user_data = ref.get()

        updates = {}

        # 1. Update basic info
        for key in ['name', 'phone', 'university']:
            if key in data:
                updates[key] = data[key]

        # 2. Handle password change securely using custom hashing
        if 'old_password' in data and 'new_password' in data:
            current_pw = data['old_password']
            new_pw = data['new_password']
            stored_hash = user_data.get('password')

            # Use custom password verification
            if not verify_password(current_pw, stored_hash):
                return jsonify({'success': False, 'message': 'Password does not match'}), 401

            # Hash new password with custom function
            new_hash = hash_password(new_pw)
            updates['password'] = new_hash

        # Perform final update
        ref.update(updates)
        return jsonify({'success': True, 'message': 'Account updated successfully'})
    
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@profile_bp.route('/upload_profile_picture/<uid>', methods=['POST'])
def upload_profile_picture(uid):
    try:
        data = request.get_json()
        base64_image = data.get('image_data')
        if not base64_image:
            return jsonify({'success': False, 'message': 'No image data provided'}), 400

        # Store directly under user's node
        ref = db.reference(f'users/{uid}')
        ref.update({'profile_image_base64': base64_image})

        return jsonify({'success': True, 'message': 'Profile picture saved privately in RTDB'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

