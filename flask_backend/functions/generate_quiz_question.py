import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate, HumanMessagePromptTemplate, SystemMessagePromptTemplate
from langchain_core.output_parsers import JsonOutputParser

chat_model = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key="AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA")

# Multiple Choice Prompt
prompt_mcq = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(
        "You are an intelligent AI tutor tasked with generating one unique, high-quality multiple-choice question (MCQ) from the provided notes.\n\n"
        "Make sure:\n"
        "- The question is not repetitive or too generic.\n"
        "- Each question should focus on a different concept or angle from the notes.\n"
        "- Avoid copying or reusing phrases from previous outputs.\n"
        "- The question should test understanding, not just recall.\n"
        "- Include exactly 4 options (A, B, C, D), only one of which is correct.\n"
        "- Mix up correct answer positions randomly across A to D.\n"
        "- Ensure all options are plausible and not too obviously wrong.\n\n"
        "Respond in the following JSON format only:\n\n"
        "{{\n"
        "  \"type\": \"multiple_choice\",\n"
        "  \"question\": \"...\",\n"
        "  \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"],\n"
        "  \"correct_answer\": \"Option B\"\n"
        "}}"
    ),
    HumanMessagePromptTemplate.from_template(
        "Generate a multiple-choice question from the following notes:\n\n{input}"
    ),
])

# True/False Prompt
prompt_tf = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(
        "You are an intelligent AI tutor generating **diverse and original** True/False questions from provided study notes.\n\n"
        "Guidelines:\n"
        "- Avoid repeating similar statements.\n"
        "- Each question must highlight a new insight or fact.\n"
        "- Do not use simple one-word statements like 'X is Y'.\n"
        "- The statement should be conceptually rich and informative.\n"
        "- Randomly choose whether the correct answer is True or False.\n"
        "- Keep the language clear and precise.\n\n"
        "Respond using this JSON format only:\n\n"
        "{{\n"
        "  \"type\": \"true_false\",\n"
        "  \"question\": \"...\",\n"
        "  \"correct_answer\": \"True\"\n"
        "}}"
    ),
    HumanMessagePromptTemplate.from_template(
        "Generate a true or false question from the following notes:\n\n{input}"
    ),
])

# Self-Explanatory Prompt
prompt_exp = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(
        "You are an AI tutor that creates one deep, open-ended self-explanatory question based on the provided notes.\n\n"
        "Requirements:\n"
        "- Avoid generic or overly simple questions.\n"
        "- Focus on questions that provoke thought or require understanding.\n"
        "- Each question must explore a **different concept** or ask for explanation of an idea.\n"
        "- Do not repeat previously asked questions.\n"
        "- Avoid starting every question with the same phrase like 'Explain...' or 'What is...'. Vary your style.\n\n"
        "Respond using this JSON format only:\n\n"
        "{{\n"
        "  \"type\": \"self_explanatory\",\n"
        "  \"question\": \"...\"\n"
        "}}"
    ),
    HumanMessagePromptTemplate.from_template(
        "Generate a self-explanatory question from the following notes:\n\n{input}"
    ),
])

output_parser = JsonOutputParser()

chain_mcq = prompt_mcq | chat_model | output_parser
chain_tf = prompt_tf | chat_model | output_parser
chain_exp = prompt_exp | chat_model | output_parser

# Functions to return JSON/dict for all question types
def generate_multiple_choice_question(notes: str) -> dict:
    return chain_mcq.invoke({"input": notes})

def generate_true_false_question(notes: str) -> dict:
    return chain_tf.invoke({"input": notes})

def generate_self_explanatory_question(notes: str) -> dict:
    return chain_exp.invoke({"input": notes})

