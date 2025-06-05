import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from .generate_quiz_question import generate_multiple_choice_question, generate_true_false_question, generate_self_explanatory_question
from .generate_quiz_answer import generate_answer_multiple_choice, generate_answer_true_false, generate_answer_explanatory
import random

# Function to generate the complete quiz
def generate_quiz(notes: str, num_questions: int = 10):
    quiz = []
    
    # List of question types
    question_types = ['multiple_choice', 'true_false', 'self_explanatory']
    
    for _ in range(num_questions):
        # Randomly choose a question type
        question_type = random.choice(question_types)
        
        # Generate the respective question
        if question_type == 'multiple_choice':
            question_data = generate_multiple_choice_question(notes)
            question = question_data['question']
            options = question_data['options']
            answer_data = generate_answer_multiple_choice(question, notes, options)
            quiz.append({"question": question, "answer": answer_data['correct_answer'],"options": options, "type": "multiple_choice"})
        
        elif question_type == 'true_false':
            question_data = generate_true_false_question(notes)
            question = question_data['question']
            answer_data = generate_answer_true_false(question, notes)
            quiz.append({"question": question, "answer": answer_data['correct_answer'], "type": "true_false"})
        
        elif question_type == 'self_explanatory':
            question_data = generate_self_explanatory_question(notes)
            question = question_data['question']
            answer_data = generate_answer_explanatory(question, notes)
            quiz.append({"question": question, "answer": answer_data['answer'], "type": "self_explanatory"})
    
    return quiz
"""
# Example of generating and printing a quiz
if __name__ == "__main__":
    notes = '''AI is becoming increasingly pervasive, with AI-powered devices now making up a significant portion of the technology landscape, and its impact on the economy is expected to be substantial. AI can perform tasks like natural language processing, facial recognition, and disease diagnosis. Beyond these applications, AI is also being used to create art, develop self-driving cars, and even assist in energy reduction efforts'''
    quiz = generate_quiz(notes, num_questions=10)

    # Print the generated quiz
    for q in quiz:
        print(f"Question: {q['question']}")
        print(f"Answer: {q['answer']}")
        print(f"Type: {q['type']}")
        print()
"""