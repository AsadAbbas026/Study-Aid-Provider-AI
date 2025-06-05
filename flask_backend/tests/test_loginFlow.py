import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import unittest
from app import app  # Assuming your app instance is here
import json
import io

class TestAuthEndpoints(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    # Test successful signup
    def test_signup_success(self):
        data = {
            'email': 'testuser@example.com',
            'password': 'TestPassword123',
            'username': 'testuser'
        }
        response = self.app.post('/api/data/signup', json=data)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'OTP sent!', response.data)
        print("Signup success test passed!")

    # Test failure when missing email or password
    def test_signup_failure_missing_data(self):
        data = {
            'email': 'testuser@example.com',
            'password': ''
        }
        response = self.app.post('/api/data/signup', json=data)
        self.assertEqual(response.status_code, 400)
        self.assertIn(b'Email and password are required!', response.data)
        print("Signup failure due to missing data passed!")

    # Test failure when user already exists
    def test_signup_failure_user_exists(self):
        # Assuming user already exists
        data = {
            'email': 'existinguser@example.com',
            'password': 'ExistingPassword123',
            'username': 'existinguser'
        }
        response = self.app.post('/api/data/signup', json=data)
        self.assertEqual(response.status_code, 400)
        self.assertIn(b'User already exists!', response.data)
        print("Signup failure due to existing user passed!")

        # Test successful login
    def test_login_success(self):
        data = {
            'email': 'testuser@example.com',
            'password': 'TestPassword123'
        }
        response = self.app.post('/api/data/login', json=data)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Login successful', response.data)
        print("Login success test passed!")

    # Test failure when user not found
    def test_login_failure_user_not_found(self):
        data = {
            'email': 'nonexistentuser@example.com',
            'password': 'SomePassword123'
        }
        response = self.app.post('/api/data/login', json=data)
        self.assertEqual(response.status_code, 404)
        self.assertIn(b'User not found', response.data)
        print("Login failure due to user not found passed!")

    # Test failure when invalid password
    def test_login_failure_invalid_password(self):
        data = {
            'email': 'testuser@example.com',
            'password': 'WrongPassword123'
        }
        response = self.app.post('/api/data/login', json=data)
        self.assertEqual(response.status_code, 401)
        self.assertIn(b'Invalid password', response.data)
        print("Login failure due to invalid password passed!")

        # Test successful OTP verification
    def test_verify_otp_success(self):
        data = {
            'email': 'testuser@example.com',
            'otp': '123456'  # Assuming the OTP is '123456' for this test case
        }
        response = self.app.post('/api/data/verify_otp', json=data)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'Signup complete via OTP!', response.data)
        print("Verify OTP success test passed!")

    # Test failure when missing email or OTP
    def test_verify_otp_failure_missing_data(self):
        data = {
            'email': '',
            'otp': ''
        }
        response = self.app.post('/api/data/verify_otp', json=data)
        self.assertEqual(response.status_code, 400)
        self.assertIn(b'Missing email or OTP', response.data)
        print("Verify OTP failure due to missing data passed!")

    # Test failure when invalid OTP
    def test_verify_otp_failure_invalid_otp(self):
        data = {
            'email': 'testuser@example.com',
            'otp': '000000'  # Invalid OTP
        }
        response = self.app.post('/api/data/verify_otp', json=data)
        self.assertEqual(response.status_code, 400)
        self.assertIn(b'Invalid or expired OTP', response.data)
        print("Verify OTP failure due to invalid OTP passed!")

class TestAudioEndpoints(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    # Test successful audio upload
    def test_upload_audio_success(self):
        data = {
            'file': (io.BytesIO(b"Fake audio content"), 'test_audio.wav')
        }
        response = self.app.post('/api/data/upload_audio', content_type='multipart/form-data', data=data)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'File uploaded successfully', response.data)
        print("Upload audio success test passed!")

    # Test upload audio failure when no file
    def test_upload_audio_failure_no_file(self):
        data = {}
        response = self.app.post('/api/data/upload_audio', content_type='multipart/form-data', data=data)
        self.assertEqual(response.status_code, 400)
        self.assertIn(b'No audio file provided', response.data)
        print("Upload audio failure due to no file passed!")

    # Test transcription failure when no audio file
    def test_transcribe_audio_failure_no_file(self):
        # First make sure temp folder is clean
        if os.path.exists('temp'):
            for filename in os.listdir('temp'):
                os.remove(os.path.join('temp', filename))

        response = self.app.post('/api/data/transcribe')
        self.assertEqual(response.status_code, 404)
        self.assertIn(b'No audio file found', response.data)
        print("Transcribe audio failure due to no file passed!")

    # You can add success transcribe test when mock audio file available
    # Example (Optional)
    # def test_transcribe_audio_success(self):
    #     pass  # Normally needs mock audio file + mocking service functions


if __name__ == '__main__':
    unittest.main()
