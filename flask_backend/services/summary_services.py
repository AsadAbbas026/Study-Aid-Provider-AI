import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from functions.generate_summary import summarize_notes

def generate_summary_from_notes(notes):
    """
    Function to generate a summary from notes using the summarization model.
    """
    summary = summarize_notes(notes)
    return summary