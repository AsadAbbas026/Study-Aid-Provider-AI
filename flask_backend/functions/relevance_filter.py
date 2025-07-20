# functions/relevance_filter.py

from typing import List
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain_google_genai import ChatGoogleGenerativeAI
import nltk

nltk.download('punkt')
from nltk.tokenize import sent_tokenize

# Setup the LLM
llm = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key="AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA")

prompt_template = PromptTemplate(
    input_variables=["sentence"],
    template="""
        You are a smart AI assistant that filters educational content from a classroom discussion.

        Label the following sentence as:
        Relevant - if it explains a concept or topic.
        Irrelevant - if it's scolding, casual talk, or unrelated.

        Sentence: "{sentence}"
        Label:"""
)  

relevance_chain = LLMChain(llm=llm, prompt=prompt_template)

def filter_relevant_sentences(transcript: str) -> List[str]:
    sentences = sent_tokenize(transcript)
    relevant = []

    for sentence in sentences:
        result = relevance_chain.run(sentence=sentence)
        if "Relevant" in result:
            relevant.append(sentence)
    return relevant
