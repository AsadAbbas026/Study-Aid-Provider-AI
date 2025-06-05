from datetime import datetime
from models.extensions import db


class Note(db.Model):
    __tablename__ = 'notes'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(80), nullable=False)  # Firebase UID
    title = db.Column(db.String(255), nullable=False)
    content = db.Column(db.Text, nullable=False)
    tags = db.Column(db.Text, nullable=True)  # Use db.Text instead of db.String(255)
    type = db.Column(db.String(50), nullable=False)  # e.g., 'Transcribed', 'Manual'
    flashcards = db.Column(db.Text, nullable=True)  # Stored as JSON string
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return f'<Note {self.title}>'
