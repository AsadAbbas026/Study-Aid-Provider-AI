import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import re
from dateutil import parser
from datetime import datetime, timedelta
import nltk
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate, HumanMessagePromptTemplate, SystemMessagePromptTemplate
from langchain_core.output_parsers import JsonOutputParser
from nltk.tokenize import sent_tokenize

nltk.download('punkt')
chat_model = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key="AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA")


# Prompt setup (moved outside the function)
rewrite_prompt = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(
        "You are a helpful AI assistant that rewrites short reminders to make them clearer, more concise, and easier to understand.\n\n"
        "Instructions:\n"
        "- Keep the intent and meaning the same.\n"
        "- Make grammar and formatting improvements.\n"
        "- Remove unnecessary words or repetition.\n"
        "- Use plain and easy-to-understand language.\n"
        "- If it contains a task or time, keep that information intact.\n"
        "- The final reminder must be written in **one single line** with no line breaks.\n\n"
        "Respond in the following JSON format only:\n"
        "{{\n"
        "  \"rewritten_reminder\": \"...\"\n"
        "}}"
    ),
    HumanMessagePromptTemplate.from_template(
        "Rewrite the following reminder:\n\n{input}"
    ),
])

output_parser = JsonOutputParser()
rewrite_chain = rewrite_prompt | chat_model | output_parser

# Enhanced helper function
def get_absolute_date(phrase, reference_date=None):
    if reference_date is None:
        reference_date = datetime.today()
    phrase = phrase.lower()

    weekday_map = {
        "monday": 0, "tuesday": 1, "wednesday": 2, "thursday": 3,
        "friday": 4, "saturday": 5, "sunday": 6
    }

    # Match phrases like "next Monday", "Monday next week"
    match = re.search(r"(next\s+week\s+)?(monday|tuesday|wednesday|thursday|friday|saturday|sunday)|(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\s+next\s+week", phrase)

    if match:
        groups = match.groups()
        weekday = groups[1] if groups[1] else groups[2]
        target_weekday = weekday_map[weekday]
        current_weekday = reference_date.weekday()

        is_next_week = "next week" in phrase
        days_ahead = (target_weekday - current_weekday + 7) % 7
        if is_next_week or days_ahead == 0:
            days_ahead += 7

        target_date = reference_date + timedelta(days=days_ahead)
        return target_date.strftime("%Y-%m-%d")

    try:
        return parser.parse(phrase, fuzzy=True).strftime("%Y-%m-%d")
    except:
        return None

def rewrite_reminder(text: str) -> dict:
    return rewrite_chain.invoke({"input": text})

# Main function with text cleanup
def extract_reminders_and_clean_text(text):
    sentences = sent_tokenize(text)
    keywords = ["quiz", "assignment", "meeting", "event", "exam", "presentation"]
    reminders = []
    reminder_sentences = []

    for sentence in sentences:
        lowered = sentence.lower()
        matched_keywords = [kw for kw in keywords if kw in lowered]

        if matched_keywords:
            date_match = re.search(
                r"(next\s+week\s+)?(monday|tuesday|wednesday|thursday|friday|saturday|sunday)|(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\s+next\s+week",
                lowered
            )

            if date_match:
                date_phrase = date_match.group()
                for keyword in matched_keywords:
                    if keyword in lowered:
                        # Get the original sentence for the reminder description
                        original_description = sentence.strip()
                        
                        # Call the AI function to rewrite the description
                        rewritten_description = rewrite_reminder(original_description)
                        clean_description = rewritten_description['rewritten_reminder']
                        
                        reminder = {
                            "title": keyword.capitalize(),
                            "description": clean_description,  # Use rewritten description
                            "date": get_absolute_date(date_phrase),
                            "time": "11:59 PM"
                        }
                        reminders.append(reminder)
                        reminder_sentences.append(sentence.strip())  # mark for removal
                        break

    # Remove the reminder sentences from original text
    clean_sentences = [s for s in sentences if s.strip() not in reminder_sentences]
    clean_text = " ".join(clean_sentences)

    return reminders, clean_text

"""
# Test
if __name__ == "__main__":
    text = '''
    Artificial Intelligence, often abbreviated as AI, refers to the simulation of human intelligence in machines that are programmed to think and learn like humans. One of the fundamental areas within AI is Machine Learning, where algorithms enable computers to learn from data and make decisions or predictions based on it. For example, supervised learning involves feeding labeled data into a model so it can learn to make accurate predictions on new, unseen data. These concepts form the backbone of many real-world applications such as voice assistants, recommendation systems, and even autonomous vehicles. Before we continue further, just a quick reminder: your first quiz will be held this Friday, and it will cover topics from the introduction to AI up to the basics of supervised learning. Also, don't forget that Assignment 1 is due by Monday, so please manage your time accordingly. Now, moving on to unsupervised learning, which deals with data that has no labels...
    '''

    reminders, cleaned_text = extract_reminders_and_clean_text(text)
    print("Reminders:")
    print(reminders)
    print("\nCleaned Text:")
    print(cleaned_text)
"""