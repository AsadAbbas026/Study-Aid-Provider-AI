import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate
from langchain_core.output_parsers import JsonOutputParser

chat_model = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key="AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA")

# Flashcard Prompt
prompt_flashcard = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(
        "You are a helpful assistant that creates flashcards from a study note. "
        "Each flashcard should include:\n"
        "- A short heading (1–5 words, summarizing a concept or idea)\n"
        "- A concise note (1–2 lines) explaining or elaborating on the heading\n\n"
        "You must:\n"
        "- Extract diverse and meaningful points from the note\n"
        "- Ensure each flashcard helps recall or understand a specific subtopic\n"
        "- Avoid question/answer format\n"
        "- Limit total flashcards to 5–8\n\n"
        "Respond in the following JSON format:\n"
        "{{\n"
        "  \"type\": \"flashcards\",\n"
        "  \"flashcards\": [\n"
        "    {{\"heading\": \"...\", \"note\": \"...\"}},\n"
        "    {{\"heading\": \"...\", \"note\": \"...\"}},\n"
        "    ...\n"
        "  ]\n"
        "}}"
    ),
    HumanMessagePromptTemplate.from_template(
        "Generate flashcards from the following study note:\n\n{input}"
    ),
])

output_parser = JsonOutputParser()

# Chain
chain_flashcard = prompt_flashcard | chat_model | output_parser

# Function
def generate_flashcards(notes: str) -> dict:
    return chain_flashcard.invoke({"input": notes})
