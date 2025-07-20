import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from functions.generate_quiz import generate_quiz
from functions.generate_quiz_results import evaluate_answer

def generate_quiz_from_notes(notes: str, num_questions: int = 6):
    """
    Generate a quiz based on the provided notes.
    
    Args:
        notes (str): The study notes to generate questions from.
        num_questions (int): The number of questions to generate. Default is 10.
        
    Returns:
        list: A list of dictionaries containing the generated quiz questions and answers.
    """
    return generate_quiz(notes, num_questions)

def process_quiz_result(question, expected_answer, user_answer):
    result = evaluate_answer(question, expected_answer, user_answer)
    # You can later parse or post-process this result here
    return result
