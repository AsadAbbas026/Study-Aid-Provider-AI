from difflib import SequenceMatcher
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from models import db, Notes

def find_similar_topic_notes(user_id, new_topic, threshold=0.7):
    """Finds the most similar topic from existing notes of the user."""
    user_notes = Notes.query.filter_by(user_id=user_id).all()
    
    best_match = None
    best_score = 0

    for note in user_notes:
        similarity_score = SequenceMatcher(None, new_topic.lower(), note.topic.lower()).ratio()
        if similarity_score > best_score and similarity_score >= threshold:
            best_match = note
            best_score = similarity_score

    return best_match

def find_similar_content_notes(user_id, new_content, threshold=0.7):
    """Finds the most similar content-based note for potential parent assignment."""
    user_notes = Notes.query.filter_by(user_id=user_id).all()
    
    if not user_notes:
        return None  # No existing notes

    existing_texts = [note.content for note in user_notes]
    vectorizer = TfidfVectorizer().fit_transform(existing_texts + [new_content])
        
    # Compute similarity scores
    similarity_matrix = cosine_similarity(vectorizer[-1], vectorizer[:-1])
    best_match_index = similarity_matrix.argmax()
    best_score = similarity_matrix[0, best_match_index]

    if best_score >= threshold:
        return user_notes[best_match_index]  # Return the most relevant parent note

    return None

def find_best_parent_note(user_id, new_topic, new_content):
    """Finds the most suitable parent note by combining topic and content similarity."""
    
    topic_based_parent = find_similar_topic_notes(user_id, new_topic)
    content_based_parent = find_similar_content_notes(user_id, new_content)

    if topic_based_parent and content_based_parent:
        # Prioritize content similarity if both are found
        return content_based_parent if content_based_parent.notes_id == topic_based_parent.notes_id else topic_based_parent
    return topic_based_parent or content_based_parent  # Return whichever is found

def create_note(user_id, topic, content, tags, type):
    """Create a note and assign a parent dynamically if applicable."""
    
    # Find the best parent note dynamically
    parent_note = find_best_parent_note(user_id, topic, content)

    new_note = Notes(
        user_id=user_id,
        topic=topic,
        content=content,
        tags=tags,
        type=type,
        parent_note_id=parent_note.notes_id if parent_note else None  # Assign parent if found
    )

    db.session.add(new_note)
    db.session.commit()

    return {"message": "Note created successfully!", "note_id": new_note.notes_id, "parent_note_id": parent_note.notes_id if parent_note else None}, 201
