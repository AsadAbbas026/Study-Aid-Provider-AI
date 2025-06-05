import smtplib
import random
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

SENDER_EMAIL = "asad.rizvi032@gmail.com"
SENDER_PASSWORD = "wgih vhxe byog plzd"

def send_otp(email):
    try:
        otp = random.randint(1000, 9999)

        subject = "Your OTP Code"
        body = f"Your OTP for account verification is: {otp}"

        message = MIMEMultipart()
        message["From"] = SENDER_EMAIL
        message["To"] = email
        message["Subject"] = subject
        message.attach(MIMEText(body, "plain"))

        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            server.sendmail(SENDER_EMAIL, email, message.as_string())

        return otp
    except Exception as e:
        print(f"Failed to send OTP: {e}")
        return None
