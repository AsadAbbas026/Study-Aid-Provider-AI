from flask import Blueprint, request, jsonify
from models.extensions import db
from models.schedules_model import StudySchedules
from datetime import datetime

ss_bp = Blueprint('study schedules', __name__)

@ss_bp.route('/add_schedule', methods=["POST"])
def add_schedule():
    data = request.get_json()
    userID = data.get('user_id')
    title = data.get('title', "")
    description = data.get('description', "")
    date_time_str = data.get('date_time', "")

    print(f"[DEBUG] UserID = {userID}, title = {title}, description = {description}, date_time = {date_time_str}")
    
    try:
        # Parse the datetime string
        dt_object = datetime.strptime(date_time_str, "%d/%m/%Y %I:%M %p")  # Expects "02/05/2025 02:10 AM"

        # Extract date and time strings separately
        date_str = dt_object.strftime("%d/%m/%Y")  # Output: "02/05/2025"
        time_str = dt_object.strftime("%I:%M %p")  # Output: "02:10 AM"

        schedule = StudySchedules(
            user_id=userID,
            schedule_title=title,
            description=description,
            date=date_str,
            time=time_str
        )

        db.session.add(schedule)
        db.session.commit()

    except Exception as e:
        return jsonify({"error": str(e)}), 400

    return jsonify({"message": "Study Schedule Added in the database", 'schedule_id': schedule.id})

@ss_bp.route('/get_schedules', methods=["POST"])
def get_all_schedules():
    data = request.get_json()
    user_id = data.get('user_id')
    if not user_id:
        return jsonify({"error": "User ID is required"}), 400

    schedules = StudySchedules.query.filter_by(user_id=user_id).all()
    schedules_list = []
    for schedule in schedules:
        schedule_data = {
            "id": schedule.id,
            "title": schedule.schedule_title,
            "description": schedule.description,
            "date": schedule.date,
            "time": schedule.time
        }
        print(f"[DEBUG] Schedule Data: {schedule_data}")
        schedules_list.append(schedule_data)
    return jsonify({"schedule_list": schedules_list}), 200

@ss_bp.route('/delete_schedule', methods=['DELETE'])
def delete_schedule():
    data = request.get_json()
    schedule_id = data.get('schedule_id')
    user_id = data.get('user_id')
    print(f"[DEBUG] Schedule ID to delete: {schedule_id}, User ID: {user_id}")
    if not schedule_id:
        return jsonify({'error': 'Schedule ID is required'}), 400
    if not user_id:
        return jsonify({'error': 'User ID is required'}), 400
    
    try:
        schedule = StudySchedules.query.filter_by(id=schedule_id, user_id=user_id).first()

        if not schedule:
            return jsonify({'error': 'Schedule not found'}), 404

        db.session.delete(schedule)
        db.session.commit()
        return jsonify({'message': 'Schedule deleted successfully'}), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500
