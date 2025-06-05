from flask import Blueprint, request, jsonify
from models.goals_model import Goal, Milestone
from models.extensions import db
from datetime import datetime
from functions.generate_goals_milestone import generate_milestones

goal_bp = Blueprint('goal', __name__)

@goal_bp.route('/add_goal', methods=['POST'])
def add_goal():
    try:
        data = request.json
        user_id = data.get('user_id')
        title = data.get('title')
        description = data.get('description')
        print("[DEBUG] User ID:", user_id)
        print("[DEBUG] Title:", title)
        print("[DEBUG] Description:", description)

        if not all([user_id, title, description]):
            return jsonify({"error": "Missing required fields"}), 400

        goal = Goal(user_id=user_id, title=title, description=description)
        db.session.add(goal)
        db.session.commit()

        return jsonify({"message": "Goal added successfully", "goal_id": goal.id}), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500
    
@goal_bp.route('/delete_goal', methods=['DELETE'])
def delete_goal():
    try:
        data = request.get_json()
        goal_id = data.get('goal_id')
        user_id = data.get('user_id')
        print(f"[DEBUG] Goal ID to delete: {goal_id}, User ID: {user_id}")

        if not goal_id:
            return jsonify({"error": "Goal ID is required"}), 400

        goal = Goal.query.filter_by(id=goal_id, user_id=user_id).first()
        print(f"[DEBUG] Goal found: {goal}")
        if not goal:
            return jsonify({"error": "Goal not found"}), 404

        db.session.delete(goal)
        db.session.commit()
        return jsonify({"message": f"Goal with ID {goal_id} deleted successfully"}), 200

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500
    
@goal_bp.route('/generate_milestone', methods=['POST'])
def generate_milestone():
    data = request.get_json()

    goal_id = data.get('goal_id')
    user_id = data.get('user_id')

    if not goal_id or not user_id:
        return jsonify({"error": "goal_id and user_id are required"}), 400

    # Check if the goal exists for the given user
    goal = Goal.query.filter_by(id=goal_id, user_id=user_id).first()
    if not goal:
        return jsonify({"error": "Goal not found for the given user"}), 404

    goal_title = goal.title
    goal_description = goal.description

    # Generate milestones using LangChain or your custom logic
    milestones_data = generate_milestones(goal_title, goal_description)

    if not milestones_data:
        return jsonify({"error": "No milestones generated"}), 400

    # Save milestones to the database
    for milestone in milestones_data:
        new_milestone = Milestone(
            title=milestone.get('title'),
            description=milestone.get('description'),
            created_at=datetime.utcnow(),
            goal_id=goal_id
        )
        db.session.add(new_milestone)

    db.session.commit()

    return jsonify({"milestones": milestones_data}), 200

@goal_bp.route('/get_all_goals', methods=['POST'])
def get_all_goals():
    data = request.get_json()  # Get JSON data from the request body
    if not data:
        return jsonify({"message": "No data provided"}), 400

    # Ensure user_id is provided in the request
    user_id = data.get('user_id')
    if not user_id:
        return jsonify({"message": "User ID is required"}), 400

    # Query to get all goals for the provided user_id
    goals = Goal.query.filter_by(user_id=user_id).all()

    # If no goals are found for the user, return a message
    if not goals:
        print("⚠️ No goals found for this user.")
        return jsonify({"message": "No goals found for this user."}), 404

    # Prepare the response with the goal details
    goal_data = []
    for goal in goals:
        goal_data.append({
            "id": str(goal.id),
            "user_id": str(goal.user_id),
            "title": goal.title,
            "description": goal.description,
            "created_at": goal.created_at.isoformat()  # better ISO format for timestamps
        })

    return jsonify({
        "message": "Goals fetched successfully",
        "goals": goal_data
    }), 200

@goal_bp.route('/get_milestones', methods=['POST'])
def get_milestones():
    data = request.get_json()
    goal_id = data.get('goal_id')

    if not goal_id:
        return jsonify({"error": "Goal ID is required"}), 400
    print(f"[DEBUG] Fetching milestones for goal ID: {goal_id}")
    milestones = Milestone.query.filter_by(goal_id=int(goal_id)).all()

    if not milestones:
        return jsonify({"message": "No milestones found for this goal."}), 404

    milestone_list = [
        {
            "id": m.id,
            "title": m.title,
            "description": m.description,
            "created_at": m.created_at
        } for m in milestones
    ]
    print(f"[DEBUG] Milestones for goal {goal_id}: {milestone_list}")
    return jsonify({
        "message": "Milestones fetched successfully",
        "milestones": milestone_list
    }), 200

@goal_bp.route('/update_goal_percentage', methods=['POST'])
def update_goal_percentage():
    data = request.get_json()
    title = data.get('title')
    percentage = data.get('percentage')

    goal = Goal.query.filter_by(title=title).first()
    if not goal:
        return jsonify({'message': 'Goal not found'}), 404

    goal.percentage = percentage
    db.session.commit()
    return jsonify({'message': 'Percentage updated successfully'}), 200
