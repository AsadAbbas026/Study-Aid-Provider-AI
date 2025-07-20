from flask import Blueprint, jsonify, session, request
from services.reminder_services import extract_reminders
from models.reminders_model import Reminders
from models.extensions import db

reminder_bp = Blueprint("reminders", __name__)

@reminder_bp.route('/create_reminder', methods=['POST'])
def create_reminder():
    data = request.get_json()
    userID = data.get('user_id')
    transcription_data = data.get('transcription_data')

    print("\n---- /create_reminder called ----")
    print("Session userID:", userID)
    print("Transcription data exists:", bool(transcription_data))
    print("Transcription data (Preview):", transcription_data[:100] if transcription_data else "None")

    if not userID or not transcription_data:
        print("[ERROR] No transcription data or userID available.")
        return jsonify({'error': 'No transcription data available'}), 400

    reminders, cleaned_transcription = extract_reminders(transcription_data)
    print("✅ Reminders extracted:", reminders)
    print("🧹 Cleaned transcription preview:", cleaned_transcription[:100])

    saved_reminders = []

    for reminder in reminders:
        new_reminder = Reminders(
            user_id=userID,
            reminder_title=reminder.get('title', 'Untitled Reminder'),
            description=reminder.get('description', ''),
            date=reminder.get('date', '1970-01-01'),
            time=reminder.get('time', '12:00 AM')
        )
        db.session.add(new_reminder)
        saved_reminders.append({
            'title': new_reminder.reminder_title,
            'description': new_reminder.description,
            'date': new_reminder.date,
            'time': new_reminder.time
        })

    db.session.commit()
    print("📦 All reminders saved to DB.")

    return jsonify({
        'message': 'Reminders created and saved',
        'reminders': saved_reminders,
        'cleaned_transcription': cleaned_transcription
    }), 200

@reminder_bp.route('/get_reminders', methods=['GET'])
def get_reminders():
    user_id = request.args.get('user_id')

    print("\n---- /get_reminders called ----")
    print("User ID:", user_id)

    if not user_id:
        return jsonify({'error': 'User ID is required'}), 400

    # Query reminders for the given user ID
    reminders = Reminders.query.filter_by(user_id=user_id).all()

    if not reminders:
        return jsonify({'message': 'No reminders found for this user', 'reminders': []}), 200

    reminders_list = []
    for r in reminders:
        reminders_list.append({
            'title': r.reminder_title,
            'description': r.description,
            'date': r.date,
            'time': r.time
        })

    print(f"✅ Total reminders fetched: {len(reminders_list)}")
    return jsonify({'reminders': reminders_list}), 200

@reminder_bp.route('/save_reminder', methods=['POST'])
def save_reminder():
    try:
        data = request.get_json()

        if not data:
            return jsonify({'error': 'No data provided'}), 400

        user_id = data.get('user_id')
        title = data.get('title')
        description = data.get('description')
        date = data.get('date')
        time = data.get('time')

        if not all([user_id, title, date, time]):
            return jsonify({'error': 'Missing required fields'}), 400

        # ✅ Create a new Reminder object
        new_reminder = Reminders(
            user_id=user_id,
            reminder_title=title,
            description=description,
            date=date,
            time=time
        )

        # ✅ Save to database
        db.session.add(new_reminder)
        db.session.commit()

        return jsonify({'message': 'Reminder saved successfully'}), 200

    except Exception as e:
        print(f'🔥 Exception occurred: {e}')
        return jsonify({'error': 'Internal server error'}), 500
    
@reminder_bp.route('/update_reminder', methods=['PUT'])
def update_reminder():
    try:
        data = request.get_json()

        reminder_id = data.get('reminder_id')
        title = data.get('title')
        description = data.get('description')
        date = data.get('date')
        time = data.get('time')

        if not reminder_id:
            return jsonify({'error': 'Reminder ID is required'}), 400

        # 🔍 Fetch the reminder
        reminder = Reminders.query.get(reminder_id)
        if not reminder:
            return jsonify({'error': 'Reminder not found'}), 404

        # ✅ Update fields only if they are present in request
        if title: reminder.reminder_title = title
        if description: reminder.description = description
        if date: reminder.date = date
        if time: reminder.time = time

        db.session.commit()

        return jsonify({'message': 'Reminder updated successfully'}), 200

    except Exception as e:
        print(f"🔥 Exception in update_reminder: {e}")
        return jsonify({'error': 'Internal server error'}), 500

@reminder_bp.route('/delete_reminder', methods=['DELETE'])
def delete_reminder():
    try:
        data = request.get_json()
        reminder_id = data.get('reminder_id')

        if not reminder_id:
            return jsonify({'error': 'Reminder ID is required'}), 400

        # 🔍 Fetch reminder
        reminder = Reminders.query.get(reminder_id)
        if not reminder:
            return jsonify({'error': 'Reminder not found'}), 404

        db.session.delete(reminder)
        db.session.commit()

        return jsonify({'message': 'Reminder deleted successfully'}), 200

    except Exception as e:
        print(f"🔥 Exception in delete_reminder: {e}")
        return jsonify({'error': 'Internal server error'}), 500
