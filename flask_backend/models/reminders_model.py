from .extensions import db

class Reminders(db.Model):
    __tablename__ = 'reminders'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(80), nullable=False)
    reminder_title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    date = db.Column(db.String(20), nullable=False)  # Format: "YYYY-MM-DD"
    time = db.Column(db.String(20), nullable=False)  # Format: "HH:MM AM/PM"

    def __repr__(self):
        return f"<Reminder {self.reminder_title} for User {self.user_id}>"
