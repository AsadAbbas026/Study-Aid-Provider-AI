from models.extensions import db

class Summary(db.Model):
    __tablename__ = 'summaries'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(80), nullable=False)  # Firebase UID
    note_id = db.Column(db.Integer, db.ForeignKey('notes.id'), nullable=False)  # Foreign key to Note
    summary_text = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=db.func.current_timestamp())
    updated_at = db.Column(db.DateTime, default=db.func.current_timestamp(), onupdate=db.func.current_timestamp())

    note = db.relationship('Note', backref='summaries')
    def __repr__(self):
        return f'<Summary {self.id} for Note {self.note_id}>'