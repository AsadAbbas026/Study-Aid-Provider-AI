import hashlib
import os

def hash_password(password, salt=None, iterations=10):
    """Hashes a password using PBKDF2 (SHA-256) with a salt."""
    if salt is None:
        salt = os.urandom(16)  # Generate a random 16-byte salt
    hashed_password = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, iterations)
    return f"{salt.hex()}${hashed_password.hex()}"

def verify_password(password, stored_hash, iterations=10):
    """Verifies a password against a stored PBKDF2 hash."""
    # DEBUG: Print hash for diagnostics
    print(f"[DEBUG] stored_hash received: {stored_hash}")

    if '$' not in stored_hash:
        raise ValueError(f"Invalid hash format: '{stored_hash}'. Expected format: <salt>$<hash>")

    try:
        salt, hashed_password = stored_hash.split('$')
        new_hash = hashlib.pbkdf2_hmac('sha256', password.encode(), bytes.fromhex(salt), iterations).hex()
        return new_hash == hashed_password
    except Exception as e:
        print(f"[ERROR] Password verification failed: {str(e)}")
        return False
