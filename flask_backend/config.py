import os
from datetime import timedelta

class Config:
    DEBUG = False
    TESTING = False
    SQLALCHEMY_TRACK_MODIFICATIONS = False  # Disable event notifications for performance
    UPLOAD_FOLDER = "uploads/audio"
    SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key")
    
    SQLALCHEMY_DATABASE_URI = 'sqlite:///studybuddy.db'  # Correct URI for SQLite
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    PERMANENT_SESSION_LIFETIME = timedelta(seconds=30)  # Auto logout after 30 sec
    SESSION_COOKIE_HTTPONLY = True  # Prevent JavaScript access to session cookies
    SESSION_COOKIE_SECURE = True   # Only allow session cookies over HTTPS
    DATABASE_URL = "https://study-buddy-system-default-rtdb.firebaseio.com"
    FIREBASE_API_KEY= "study-buddy-system-firebase-adminsdk-fbsvc-2ac7bab16e.json"
    # Firebase Configuration (add actual details here)
    #FIREBASE_API_KEY = os.getenv('FIREBASE_API_KEY', 'your_firebase_api_key')
    #FIREBASE_AUTH_DOMAIN = os.getenv('FIREBASE_AUTH_DOMAIN', 'your_auth_domain')
    #FIREBASE_PROJECT_ID = os.getenv('FIREBASE_PROJECT_ID', 'your_project_id')
    SESSION_TYPE = 'filesystem'
    SESSION_FILE_DIR = './flask_session_data'  # Custom folder to store sessions
    SESSION_PERMANENT = False  # Only lasts for the browser session
    SESSION_USE_SIGNER = True  # Adds extra security
    SESSION_COOKIE_HTTPONLY = True  # Prevent JS access
    SESSION_COOKIE_SECURE = True  # Only allow cookies over HTTPS
    PERMANENT_SESSION_LIFETIME = timedelta(minutes=30)  # Optional timeout

class DevelopmentConfig(Config):
    DEBUG = True  # Enable debug mode

class ProductionConfig(Config):
    DEBUG = False  # Disable debug mode
