from .extensions import db

class StudySchedules(db.Model):
    __tablename__ = 'study_schedules'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(80), nullable=False)
    schedule_title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    date = db.Column(db.String(20), nullable=False)
    time = db.Column(db.String(20), nullable=False)

    def __repr__(self):
        return f"<Study Schedule {self.schedule_title} for User {self.user_id}>"
