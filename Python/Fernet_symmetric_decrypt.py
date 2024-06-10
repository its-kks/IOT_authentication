from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64

def get_key(password: str):
    
    password = password.encode()  
    salt = b'salt_'  
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=100000,
    )
    key = base64.urlsafe_b64encode(kdf.derive(password))  
    return key

def decrypt_message(encrypted_message, user_key):

    key = get_key(user_key)

    f = Fernet(key)
    decrypted_message = f.decrypt(encrypted_message)
    return decrypted_message.decode()

print(decrypt_message("gAAAAABmPMh0g4e6b03DXWi1fza-HpnD4IlpQHlH6yc3Wqd88yEbmqRkaAsS0wYFD8jESIpqQJx-lNjYgbF-bkBTXLYX1vBamw==","55"))