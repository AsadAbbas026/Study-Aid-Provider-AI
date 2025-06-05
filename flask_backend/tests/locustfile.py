from locust import HttpUser, task, between
import imaplib
import email
import re
import time
import uuid
from email.utils import parsedate_to_datetime
from datetime import datetime, timedelta
import pytz  # For timezone handling

# --- Email Configuration ---
RECEIVER_EMAIL = "aarizy.2k@gmail.com"
RECEIVER_PASSWORD = "rtwt uxvm urup vfxq"
IMAP_SERVER = "imap.gmail.com"
IMAP_PORT = 993

# --- Helper Function: Extract OTP (without deleting email first) ---
def fetch_latest_otp_from_gmail(subject_keyword="Your OTP", timeout=20, max_attempts=10):
    for attempt in range(max_attempts):
        try:
            mail = imaplib.IMAP4_SSL(IMAP_SERVER)
            mail.login(RECEIVER_EMAIL, RECEIVER_PASSWORD)
            mail.select("inbox")

            result, data = mail.search(None, f'(SUBJECT "{subject_keyword}")')
            mail_ids = data[0].split()

            if mail_ids:
                latest_email_id = mail_ids[-1]
                result, message_data = mail.fetch(latest_email_id, "(RFC822)")
                raw_email = message_data[0][1]

                msg = email.message_from_bytes(raw_email)
                email_body = ""

                if msg.is_multipart():
                    for part in msg.walk():
                        if part.get_content_type() == "text/plain":
                            email_body = part.get_payload(decode=True).decode()
                            break
                else:
                    email_body = msg.get_payload(decode=True).decode()

                print("EMAIL BODY >>>", email_body)

                # Convert both datetime objects to UTC-aware datetime
                date_tuple = parsedate_to_datetime(msg["Date"]).astimezone(pytz.UTC)
                if datetime.utcnow().astimezone(pytz.UTC) - date_tuple > timedelta(minutes=2):
                    print("OTP email too old, skipping...")
                    mail.logout()
                    continue

                otp_match = re.search(r'\b\d{4,6}\b', email_body)
                if otp_match:
                    otp_code = otp_match.group(0)

                    # DELETE ONLY AFTER OTP IS SUCCESSFULLY EXTRACTED
                    mail.store(latest_email_id, "+FLAGS", "\\Deleted")
                    mail.expunge()

                    mail.logout()
                    return otp_code

            mail.logout()

        except Exception as e:
            print(f"[Attempt {attempt + 1}] Gmail OTP fetch error: {str(e)}")

        time.sleep(timeout / max_attempts)

    return None

# --- Locust Test Class ---
class WebsiteUser(HttpUser):
    wait_time = between(1, 3)

    @task
    def signup_verify_login_flow(self):
        password = "YourSecurePassword123"
        unique_username = f"user_{uuid.uuid4().hex[:8]}"

        print(f"Starting signup with: {RECEIVER_EMAIL} and username: {unique_username}")

        # 1. Signup
        with self.client.post(
            "/api/data/signup",
            json={"email": RECEIVER_EMAIL, "password": password, "username": unique_username},
            catch_response=True
        ) as signup_response:
            if signup_response.status_code == 200:
                signup_response.success()
                print("Signup successful")
            else:
                signup_response.failure("Signup failed")
                return

        # 2. Wait for OTP email to arrive
        time.sleep(4)

        # 3. Fetch OTP
        otp_code = fetch_latest_otp_from_gmail()

        if not otp_code:
            print("Failed to retrieve OTP")
            return

        print(f"Fetched OTP: {otp_code}")
        print("Sending OTP verification request...")

        # 4. Verify OTP
        try:
            with self.client.post(
                "/api/data/verify_otp",
                json={"email": RECEIVER_EMAIL, "otp": otp_code},
                catch_response=True
            ) as verify_response:
                print("OTP verification response received")

                if verify_response.status_code == 200:
                    verify_response.success()
                    print("OTP verification successful")
                else:
                    verify_response.failure("OTP Verification failed")
                    print(f"OTP Verification failed with status code: {verify_response.status_code}, response: {verify_response.text}")
                    return
        except Exception as e:
            print(f"Exception during OTP verification: {e}")
            return

        # 5. Login
        with self.client.post(
            "/api/data/login",
            json={"email": RECEIVER_EMAIL, "password": password},
            catch_response=True
        ) as login_response:
            if login_response.status_code == 200:
                login_response.success()
                print("Login successful")
            else:
                login_response.failure("Login failed")
