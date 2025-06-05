from flask import Blueprint, request, jsonify
from models.extensions import db
from models.goals_model import Goal, Milestone
from models.quiz_model import Quiz, QuizResult

from datetime import datetime, timedelta

progress_bp = Blueprint('progress_overview', __name__)

@progress_bp.route('/quiz_progress/<user_id>', methods=['GET'])
def get_quiz_progress(user_id):
    try:
        quizzes = Quiz.query.filter_by(user_id=user_id).all()

        if not quizzes:
            return jsonify({"message": "No quizzes found for this user."}), 404

        quizzes_data = []

        for quiz in quizzes:
            result = QuizResult.query.filter_by(quiz_id=quiz.id, user_id=user_id).order_by(QuizResult.created_at.desc()).first()
            if result:
                quizzes_data.append({
                    "title": quiz.title,
                    "totalMarks": result.total_questions,  # Changed from total_marks to total_questions
                    "obtainedMarks": result.correct_answers,  # Changed from obtained_marks to correct_answers
                })

        if not quizzes_data:
            return jsonify({"message": "No quiz results found for this user."}), 404

        return jsonify(quizzes_data), 200

    except Exception as e:
        print(f"Error fetching quiz progress: {e}")
        return jsonify({"error": "Internal Server Error"}), 500

@progress_bp.route('/goal_progress/<user_id>', methods=['GET'])
def get_goal_progress(user_id):
    try:
        # Get goals from last 7 days
        seven_days_ago = datetime.utcnow() - timedelta(days=7)
        goals = Goal.query.filter(
            Goal.user_id == user_id,
            Goal.created_at >= seven_days_ago
        ).order_by(Goal.created_at).all()

        if not goals:
            return jsonify({"message": "No goals found for this period"}), 404

        # Return individual goals with their details
        progress_data = [
            {
                "date": goal.created_at.strftime("%d/%m %H:%M"),  # Include time for uniqueness
                "goalPercentage": goal.percentage,
                "title": goal.title,  # Include goal title
                "goalId": goal.id  # Include goal ID for reference
            }
            for goal in goals
        ]

        return jsonify(progress_data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500