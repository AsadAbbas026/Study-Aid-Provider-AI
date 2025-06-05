import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from functions.reminder_functions import extract_reminders_and_clean_text

def extract_reminders(text):
    reminders, clean_text =  extract_reminders_and_clean_text(text)

    return reminders, clean_text