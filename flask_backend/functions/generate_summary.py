from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate
from langchain.prompts import HumanMessagePromptTemplate, SystemMessagePromptTemplate
from langchain_core.output_parsers import StrOutputParser
import os

chat_model = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key="AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA")

prompt = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template("You are a helpful assistant that summarizes study notes within a single paragraph with only the key point concepts."),
    HumanMessagePromptTemplate.from_template("{input}"),
])

output_parser = StrOutputParser()


chain = prompt | chat_model | output_parser

def summarize_notes(notes: str) -> str:
    return chain.invoke(notes)
