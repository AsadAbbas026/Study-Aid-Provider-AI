from flask import Blueprint, request, jsonify
from firebase.firebase import get_user_data, db
from utils.otp_utils import store_otp, verify_otp
from utils.email_utils import send_otp
from utils.hash_utils import hash_password, verify_password
import uuid
import logging

auth_bp = Blueprint('auth', __name__)

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
email = None  # Global variable to store email for OTP verification

@auth_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    username = data.get('username')

    # Log the data to ensure they are being passed correctly
    logger.info(f"Signup data received: email={email}, password={password}, username={username}")

    if not email or not password:
        return jsonify({'message': 'Email and password are required!'}), 400

    # Check if user exists in Firebase before sending OTP
    existing_user = get_user_data(email)
    if existing_user:
        return jsonify({'message': 'User already exists!'}), 400

    try:
        # Generate OTP and store temporarily
        otp = send_otp(email)
        store_otp(email, otp, username, password)  # Store OTP temporarily (not in Firebase)

        return jsonify({'message': 'OTP sent! Check your email for the verification link.'}), 200
    except Exception as e:
        logger.error(f"Signup Error: {e}")
        return jsonify({'message': f'Error: {str(e)}'}), 500


@auth_bp.route('/login', methods=['POST'])
def login():
    email = request.json.get('email')
    password = request.json.get('password')

    # Get user data by email (including the UID and password)
    user_info = get_user_data(email)

    if user_info:
        # Check if the user data is in the correct format
        if 'error' in user_info:
            return jsonify(user_info), 400
        
        stored_password = user_info['data'].get('password')

        if verify_password(password, stored_password):
            return jsonify({"message": "Login successful", "uid": user_info['uid']})
        else:
            return jsonify({"message": "Invalid password"}), 401

    return jsonify({"message": "User not found"}), 404

@auth_bp.route('/verify_otp', methods=['POST'])
def verify():
    data = request.get_json()
    email = data.get('email')
    otp = data.get('otp')

    if not email or not otp:
        return jsonify({'message': 'Missing email or OTP'}), 400
    print(f"Verifying OTP for email: {email} and OTP: {otp}")
    user_data = verify_otp(email, int(otp))  # Verify OTP
    if not user_data:
        return jsonify({'message': 'Invalid or expired OTP'}), 400
    print(f"User data after OTP verification: {user_data}")
    try:
        # Now that OTP is verified, create the user in Firebase
        user_id = str(uuid.uuid4())
        hashed_password = hash_password(user_data['password'])

        ref = db.reference('users')
        ref.child(user_id).set({
            'user_id': user_id,
            'username': user_data['username'],
            'email': email,
            'password': hashed_password
        })

        return jsonify({'message': 'Signup complete via OTP!', 'user_id': user_id}), 200
    except Exception as e:
        logger.error(f"Verify OTP Error: {e}")
        return jsonify({'message': f'Error: {str(e)}'}), 500

