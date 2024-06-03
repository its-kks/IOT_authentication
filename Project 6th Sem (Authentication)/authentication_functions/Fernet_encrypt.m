function [encrypted_data] = Fernet_encrypt(data,user_key)
    %FERNET_ENCRYPT Symmetric encryption
    
    py_code = [
        "from cryptography.fernet import Fernet"
        "from cryptography.hazmat.primitives import hashes"
        "from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC"
        "import base64"
        ""
        "def get_key(password):"
        "    "
        "    password = password.encode()  "
        "    salt = b'salt_'  "
        "    kdf = PBKDF2HMAC("
        "        algorithm=hashes.SHA256(),"
        "        length=32,"
        "        salt=salt,"
        "        iterations=100000,"
        "    )"
        "    key = base64.urlsafe_b64encode(kdf.derive(password))  "
        "    return key"
        ""
        "def encrypt_message(message, user_key):"
        ""
        "    message = str(message)"
        "    user_key = str(user_key)"
        "    key = get_key(user_key); "
        ""
        "    encoded_message = message.encode()"
        "    f = Fernet(key)"
        "    encrypted_message = f.encrypt(encoded_message)"
        "    return encrypted_message.decode()"
        ];

    pyrun(py_code);

    encrypted_data = string(pyrun(strcat("ans = encrypt_message('",string(data),"',",string(user_key),")"),"ans"));
    
end

