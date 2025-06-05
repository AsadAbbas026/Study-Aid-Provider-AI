from .extensions import db
from datetime import datetime

class Goal(db.Model):
    __tablename__ = "goals"

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String, nullable=False)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=True)
    percentage = db.Column(db.Integer, default=0)  # ✅ Store overall goal completion here
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    milestones = db.relationship('Milestone', backref='goal', cascade="all, delete-orphan")

    def __repr__(self):
        return f'<Goal {self.title}>'

class Milestone(db.Model):
    __tablename__ = "milestones"

    id = db.Column(db.Integer, primary_key=True)
    goal_id = db.Column(db.Integer, db.ForeignKey('goals.id'), nullable=False)
    title = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=True)
    completed = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<Milestone {self.title}>'
