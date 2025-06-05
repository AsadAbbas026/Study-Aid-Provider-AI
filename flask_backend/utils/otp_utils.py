otp_store = {}

def store_otp(email, otp, username, password):
    otp_store[email] = {'otp': otp, 'username': username, 'password': password}

def verify_otp(email, otp):
    if email in otp_store and otp_store[email]['otp'] == otp:
        return otp_store.pop(email)  
    return None
