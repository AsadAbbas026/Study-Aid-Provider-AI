from flask import Flask
from config import Config
from flask_session import Session
from flask_cors import CORS
from firebase.firebase import initialize_firebase
from routes.auth_routes import auth_bp
from routes.note_routes import note_bp
from routes.audio_routes import audio_bp
from routes.summaries_routes import summary_bp
from routes.quiz_routes import quiz_bp
from routes.reminders_routes import reminder_bp
from routes.studySchedules_routes import ss_bp
from routes.goal_routes import goal_bp
from routes.progress_routes import progress_bp
from routes.profile_routes import profile_bp
from routes.flashcard_routes import flashcard_bp
from models.extensions import db

app = Flask(__name__)
app.config.from_object(Config)

CORS(app)
# Initialize Flask-Session with your app
Session(app)

# Initialize Firebase
initialize_firebase()

# Initialize Database
db.init_app(app)

with app.app_context():
    # Create all tables
    db.create_all()

# Register routes
app.register_blueprint(auth_bp, url_prefix='/api/data')
app.register_blueprint(profile_bp, url_prefix='/api/data')
app.register_blueprint(audio_bp, url_prefix='/api/data')
app.register_blueprint(note_bp, url_prefix='/api/data')
app.register_blueprint(flashcard_bp, url_prefix='/api/data')
app.register_blueprint(summary_bp, url_prefix='/api/data')
app.register_blueprint(reminder_bp, url_prefix='/api/data')
app.register_blueprint(quiz_bp, url_prefix='/api/data')
app.register_blueprint(ss_bp, url_prefix='/api/data')
app.register_blueprint(goal_bp, url_prefix='/api/data')
app.register_blueprint(progress_bp, url_prefix='/api/data')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
