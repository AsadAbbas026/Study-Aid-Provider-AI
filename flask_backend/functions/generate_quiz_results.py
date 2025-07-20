from langchain_core.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.output_parsers import JsonOutputParser
import json

# Output parser
json_parser = JsonOutputParser()

# Stricter prompt template
prompt = PromptTemplate(
    template="""
You are an academic evaluator. You MUST respond ONLY in valid JSON format. 
Do NOT add any commentary or text before or after the JSON object.

Your goal is to help the student improve based on their answer.

Question: {question}
Expected Answer: {expected_answer}
User's Answer: {user_answer}

Evaluate the user's answer strictly but constructively. Respond with:
- status: "Correct" or "Incorrect"
- explanation: Why it’s right or wrong
- feedback: How the user can improve

Example:
{{
  "status": "Correct",
  "explanation": "The user's answer closely matches the expected explanation with good reasoning.",
  "feedback": "Continue practicing with more real-world examples to reinforce the concept."
}}
""",
    input_variables=["question", "expected_answer", "user_answer"]
)

# LLM Initialization
llm = ChatGoogleGenerativeAI(
    model="gemini-2.5-flash",
    api_key="AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA"
)
# Evaluation chain
evaluation_chain = llm | prompt | json_parser

# Evaluation function with error handling
def evaluate_answer(question: str, expected_answer: str, user_answer: str) -> dict:
    input_data = {
        "question": question,
        "expected_answer": expected_answer,
        "user_answer": user_answer
    }

    try:
        result = evaluation_chain.invoke(input_data)
        print("✅ Parsed Result from Gemini:", result)
        return result
    except Exception as e:
        print("❌ Parsing failed with error:", e)
        return {
            "status": "Incorrect",
            "explanation": "Evaluation failed due to a parsing issue.",
            "feedback": "Please check your answer or try again later."
        }
