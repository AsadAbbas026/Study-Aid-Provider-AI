import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate, HumanMessagePromptTemplate, SystemMessagePromptTemplate
from langchain_core.output_parsers import JsonOutputParser

chat_model = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key="AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA")
output_parser = JsonOutputParser()

# Multiple Choice Answer Generator (JSON output)
def generate_answer_multiple_choice(question: str, notes: str, options: list) -> dict:
    options_str = "\n".join([f"{chr(65 + i)}. {opt}" for i, opt in enumerate(options)])

    prompt = ChatPromptTemplate.from_messages([
        SystemMessagePromptTemplate.from_template(
            "You are a helpful assistant that selects the correct answer for a multiple choice question based on the study notes.\n"
            "Return your answer strictly in this JSON format:\n"
            "{{\n"
            "  \"correct_answer\": \"<Option Text>\"\n"
            "}}"
        ),
        HumanMessagePromptTemplate.from_template(
            "Notes:\n{notes}\n\nQuestion:\n{question}\n\nOptions:\n{options_str}"
        )
    ])

    chain = prompt | chat_model | output_parser
    return chain.invoke({"question": question, "notes": notes, "options_str": options_str})


# True/False Answer Generator (JSON output)
def generate_answer_true_false(question: str, notes: str) -> dict:
    prompt = ChatPromptTemplate.from_messages([
        SystemMessagePromptTemplate.from_template(
            "You are a helpful assistant that answers true/false questions based on the study notes.\n"
            "Return your answer strictly in this JSON format:\n"
            "{{\n"
            "  \"correct_answer\": \"True\"\n"
            "}}"
        ),
        HumanMessagePromptTemplate.from_template(
            "Notes:\n{notes}\n\nQuestion:\n{question}"
        )
    ])

    chain = prompt | chat_model | output_parser
    return chain.invoke({"question": question, "notes": notes})

# Self-Explanatory Answer Generator (JSON output)
def generate_answer_explanatory(question: str, notes: str) -> dict:
    prompt = ChatPromptTemplate.from_messages([
        SystemMessagePromptTemplate.from_template(
            "You are a helpful assistant that answers descriptive questions based on the study notes.\n"
            "Return your answer strictly in this JSON format:\n"
            "{{\n"
            "  \"answer\": \"<Your Answer Here>\"\n"
            "}}"
        ),
        HumanMessagePromptTemplate.from_template(
            "Notes:\n{notes}\n\nQuestion:\n{question}"
        )
    ])

    chain = prompt | chat_model | output_parser
    return chain.invoke({"question": question, "notes": notes})
