from models.extensions import db
from datetime import datetime
from enum import Enum


class QuestionTypeEnum(Enum):
    MULTIPLE_CHOICE = 'multiple_choice'
    TRUE_FALSE = 'true_false'
    SELF_EXPLANATORY = 'self_explanatory'


class Quiz(db.Model):
    __tablename__ = 'quizzes'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.String(80), nullable=False)  # Firebase UID
    title = db.Column(db.String(255), nullable=False)
    note_id = db.Column(db.Integer, nullable=True)  # Optional: reference to note used for quiz generation

    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    questions = db.relationship('QuizQuestion', backref='quiz', lazy=True, cascade='all, delete-orphan')
    answers = db.relationship('Answer', backref='quiz', lazy=True, cascade='all, delete-orphan')
    feedback = db.relationship('Feedback', backref='quiz', lazy=True, cascade='all, delete-orphan')
    results = db.relationship('QuizResult', backref='quiz', lazy=True, cascade='all, delete-orphan')

    def __repr__(self):
        return f'<Quiz {self.title}>'


class QuizQuestion(db.Model):
    __tablename__ = 'quiz_questions'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    quiz_id = db.Column(db.Integer, db.ForeignKey('quizzes.id', ondelete='CASCADE'), nullable=False)
    question_text = db.Column(db.Text, nullable=False)
    options = db.Column(db.JSON, nullable=True)  # Null if not multiple_choice
    answer = db.Column(db.String(255), nullable=False)
    ai_answer = db.Column(db.Text, nullable=True)
    explanation = db.Column(db.Text, nullable=True)
    question_type = db.Column(db.Enum(QuestionTypeEnum), nullable=False)

    answers = db.relationship('Answer', backref='question', lazy=True)

    def __repr__(self):
        return f'<QuizQuestion {self.question_text}>'


class Answer(db.Model):
    __tablename__ = 'answers'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    question_id = db.Column(db.Integer, db.ForeignKey('quiz_questions.id'), nullable=False)
    quiz_id = db.Column(db.Integer, db.ForeignKey('quizzes.id'), nullable=False)
    user_id = db.Column(db.String(80), nullable=False)  # Firebase UID
    answer_text = db.Column(db.Text, nullable=False)
    is_correct = db.Column(db.Boolean, default=False)

    def __repr__(self):
        return f'<Answer {self.answer_text}>'


class Feedback(db.Model):
    __tablename__ = 'feedback'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    quiz_id = db.Column(db.Integer, db.ForeignKey('quizzes.id'), nullable=False)
    user_id = db.Column(db.String(80), nullable=False)  # Firebase UID
    feedback_text = db.Column(db.Text, nullable=False)

    def __repr__(self):
        return f'<Feedback {self.feedback_text}>'


class QuizResult(db.Model):
    __tablename__ = 'quiz_results'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    quiz_id = db.Column(db.Integer, db.ForeignKey('quizzes.id'), nullable=False)
    user_id = db.Column(db.String(80), nullable=False)  # Firebase UID
    score = db.Column(db.Float, nullable=False)
    total_questions = db.Column(db.Integer, nullable=True)
    correct_answers = db.Column(db.Integer, nullable=True)
    duration_seconds = db.Column(db.Integer, nullable=True)

    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<QuizResult {self.score}>'
