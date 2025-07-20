from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.prompts import ChatPromptTemplate, HumanMessagePromptTemplate, SystemMessagePromptTemplate
from langchain_core.output_parsers import JsonOutputParser

# Initialize Gemini
chat_model = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key="AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA")

# Milestone prompt template
milestone_prompt = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(
        "You are an AI assistant helping students break down their learning goals into clear and achievable milestones.\n"
        "Based on the goal title and description provided, generate a list of 3 to 5 helpful milestones.\n"
        "Each milestone must have a short title and a brief description.\n"
        "Format your response as a list of JSON objects like:\n"
        "[\n"
        "  {{\"title\": \"Milestone 1 title\", \"description\": \"What needs to be achieved\"}},\n"
        "  {{\"title\": \"Milestone 2 title\", \"description\": \"...\"}}\n"
        "]"
    ),
    HumanMessagePromptTemplate.from_template(
        "Goal Title: {title}\nGoal Description: {description}\n\nGenerate milestones."
    ),
])

output_parser = JsonOutputParser()
milestone_chain = milestone_prompt | chat_model | output_parser

# The actual function to call
def generate_milestones(title: str, description: str) -> list:
    response = milestone_chain.invoke({
        "title": title,
        "description": description
    })
    return response
"""
if __name__ == "__main__":
    # Example usage
    title = "Learn Python Programming"
    description = "I want to learn Python programming to build web applications."
    milestones = generate_milestones(title, description)
    for milestone in milestones:
        print(f"Title: {milestone['title']}\n")
        print(f"Description: {milestone['description']}\n")
        print("-" * 40)
    print("Milestones generated successfully.")
"""