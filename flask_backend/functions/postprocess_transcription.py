from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_ollama import ChatOllama
from langchain.schema import SystemMessage, HumanMessage
import time
import re

chat_model = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key="AIzaSyCXxpGfK5AQxOWRcfTaKCb7KCHhG6AxojA")

def extract_topics_and_subheadings(text):
    """Extracts the main topic and subheadings from transcribed text."""
    
    main_topic_messages = [
        SystemMessage(content="""
        Analyze the given text and extract the main topic concisely. The topic should:
        1. Be highly relevant and accurately summarize the core idea.
        2. Be short yet descriptive (between 4 to 8 words).
        3. Avoid unnecessary words like ‘An Introduction to’ or ‘Overview of’.
        4. Maintain clarity and specificity.
        5. Ensure it is different from subheadings.
        """),
        HumanMessage(content=text)
    ]
    sub_topic_messages = [
        SystemMessage(content="Analyze the given text and extract: 1. A list of structured subheadings."),
        HumanMessage(content=text)
    ]

    main_response = chat_model.invoke(main_topic_messages)
    sub_response = chat_model.invoke(sub_topic_messages)

    main_extracted_data = main_response.content.strip()
    sub_extracted_data = sub_response.content.strip()

    return main_extracted_data, sub_extracted_data

subscript_map = {
    "0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄", 
    "5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉",
    "a": "ₐ", "e": "ₑ", "h": "ₕ", "i": "ᵢ", "j": "ⱼ", 
    "k": "ₖ", "l": "ₗ", "m": "ₘ", "n": "ₙ", "o": "ₒ", 
    "p": "ₚ", "r": "ᵣ", "s": "ₛ", "t": "ₜ", "u": "ᵤ", 
    "v": "ᵥ", "x": "ₓ", "z": "𝑧", "-z": "-𝑧"
}

superscript_map = {
    "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴", 
    "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹",
    "+": "⁺", "-": "⁻", "=": "⁼", "(": "⁽", ")": "⁾",
    "n": "ⁿ", "i": "ⁱ", "x": "ˣ", "y": "ʸ", "z": "ᶻ"
}

def convert_subscripts(text):
    """Replace <sub>...</sub> tags with proper Unicode subscripts."""
    
    def replace_match(match):
        sub_text = match.group(1)
        return "".join(subscript_map.get(char, char) for char in sub_text)

    return re.sub(r"<sub>(.*?)</sub>", replace_match, text)

def convert_superscripts(text):
    """Replace <sup>...</sup> tags with proper Unicode superscripts."""
    
    def replace_match(match):
        sup_text = match.group(1)
        return "".join(superscript_map.get(char, char) for char in sup_text)

    return re.sub(r"<sup>(.*?)</sup>", replace_match, text)

def clean_html_tags(text):
    """Removes any remaining HTML-like tags (e.g., <b>, <i>)."""
    return re.sub(r"</?[^>]+>", "", text)

def process_text(text):
    """Applies all post-processing functions for subscripts, superscripts, and HTML tags."""
    text = convert_superscripts(text)
    text = convert_subscripts(text)
    text = clean_html_tags(text)
    return text

def clean_and_format_text(text):
    """Cleans up unnecessary asterisks, fixes headings, and improves readability."""
    text = re.sub(r'-\*', '', text)
    text = re.sub(r'\*\*([IVXLCDM]+\..*?)\*\*', r'**\1**', text)
    text = re.sub(r'^\*\s*', '', text, flags=re.MULTILINE)    
    text = re.sub(r'\n\s*\*\s+', '\n- ', text)  
    return text.strip()

def format_notes(text, extracted_subheadings, language_code):
    """Generates structured notes based on extracted topics & subheadings."""

    if language_code in ["ur", "hi", "ps", "pa", "sd", "ar"]:
        instruction = f"""
        آپ ایک طالب علم دوست نوٹ بنانے والے AI ہیں۔
        دیے گئے ٹرانسکرائب شدہ مواد کو اچھے اور جامع نوٹس میں تبدیل کریں۔

        **قواعد:**
        1. ہر اہم عنوان کے لیے واضح عنوان دیں۔
        2. ذیلی عنوانات استعمال کریں تاکہ مواد کو واضح بنایا جا سکے۔
        3. تعارف، وضاحت، اور مثالیں شامل کریں۔
        4. بلٹ پوائنٹس کا استعمال کریں۔
        5. اصل مواد کا ترجمہ نہ کریں، صرف اسے بہتر انداز میں ترتیب دیں۔
        6. صرف مواد پر توجہ دیں، اس کی کوالٹی پر رائے نہ دیں۔
        """
    else:
        instruction = """
        You are a student-friendly note-taking AI. Format the transcribed text into well-structured, detailed, and comprehensive notes.

        **Rules:**
        1. Use `# Title` for the main topic.
        2. Use `## Subheading` for subtopics.
        3. Start with an **introduction** to the topic.
        4. Explain every formula and concept thoroughly.
        5. Expand on every idea – include background, importance, and functionality.
        6. Give real-world examples where possible.
        7. Use bullet points `-` for clarity.
        8. Avoid summarization; ensure in-depth explanations.
        9. Explain each formula step-by-step before showing it.
        10. Keep language clear and simple.
        11. Add context and motivation behind every concept.
        12. **Do NOT include opinions on the transcription quality.**
        13. **Only focus on restructuring and improving the content.**
        """

    messages = [
        SystemMessage(content=instruction),
        HumanMessage(content=f"Transcribed Text:\n{text}\n\nExtracted Topics & Subheadings:\n{extracted_subheadings}")
    ]

    response = chat_model.invoke(messages)
    structured_notes = response.content.strip()
    structured_notes = clean_and_format_text(structured_notes)
    structured_notes = process_text(structured_notes)
    return structured_notes

def post_process_transcriptions(data):
    """Main function to post-process transcriptions."""

    start_time = time.time()
    topics, subheadings = extract_topics_and_subheadings(data)

    print("\n🔹 **Extracted Main Topic & Subheadings:**\n")
    print("Main Topic:", topics + "\n")
    print("Subheadings:", subheadings)

    formatted_notes = format_notes(data, subheadings, language_code=None)
    tags = extract_tags(formatted_notes)

    print("\nFormatted Notes:\n", formatted_notes)
    print("\nTags:", tags)

    with open("formatted_notes.txt", "w", encoding="utf-8") as f:
        f.write(formatted_notes)

    end_time = time.time()
    print("\n🕒 Execution Time:", round(end_time - start_time, 2), "seconds")
    return formatted_notes, tags, topics

def extract_tags(text):
    """Uses Gemini AI to extract relevant tags from transcribed text."""
    
    tag_extraction_messages = [
        SystemMessage(content="""
            Analyze the given text and generate relevant tags.
            **Rules:**
            1. Keep each tag between 1 to 3 words.
            2. Only include important concepts.
            3. Use common keywords students would search for.
            4. Avoid redundancy.
            5. Return a comma-separated list.
        """),
        HumanMessage(content=text)
    ]

    response = chat_model.invoke(tag_extraction_messages)
    tags = response.content.strip()
    return [tag.strip() for tag in tags.split(",")]

if __name__ == "__main__":
    post_process_transcriptions("C:\\Users\\ALRASHIDS\\Desktop\\FYP\\study_buddy\\flask_backend\\services\\transcription1.txt")
