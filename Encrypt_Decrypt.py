# from cryptography.hazmat.primitives import serialization
# from cryptography.hazmat.primitives.asymmetric import rsa
# from cryptography.hazmat.primitives import hashes
# from cryptography.hazmat.primitives.asymmetric import padding

# # Node1: Generate a private key
# private_key = rsa.generate_private_key(
#     public_exponent=65537,
#     key_size=2048,
# )

# # Node1: Generate the public key
# public_key = private_key.public_key()

# # Node1: Serialize the public key
# pem = public_key.public_bytes(
#     encoding=serialization.Encoding.PEM,
#     format=serialization.PublicFormat.SubjectPublicKeyInfo
# )

# # Node2: Load the public key
# public_key = serialization.load_pem_public_key(pem)

# # Node1: Encrypt the message
# message = b"Hello, Node2!"
# ciphertext = public_key.encrypt(
#     message,
#     padding.OAEP(
#         mgf=padding.MGF1(algorithm=hashes.SHA256()),
#         algorithm=hashes.SHA256(),
#         label=None
#     )
# )

# # Node2: Decrypt the message
# plaintext = private_key.decrypt(
#     ciphertext,
#     padding.OAEP(
#         mgf=padding.MGF1(algorithm=hashes.SHA256()),
#         algorithm=hashes.SHA256(),
#         label=None
#     )
# )

# print(plaintext)


# "from cryptography.hazmat.primitives import serialization",
# "from cryptography.hazmat.primitives.asymmetric import rsa",
# "from cryptography.hazmat.primitives import hashes",
# "from cryptography.hazmat.primitives.asymmetric import padding",



# "def send_securely_rsa(message):",
# "    # Node1: Generate a private key",
# "    private_key = rsa.generate_private_key(",
# "        public_exponent=65537,",
# "        key_size=2048,",
# "    )",
# "",
# "    # Node1: Generate the public key",
# "    public_key = private_key.public_key()",
# "",
# "    # Node1: Serialize the public key",
# "    pem = public_key.public_bytes(",
# "        encoding=serialization.Encoding.PEM,",
# "        format=serialization.PublicFormat.SubjectPublicKeyInfo",
# "    )",
# "",
# "    # Node2: Load the public key",
# "    public_key = serialization.load_pem_public_key(pem)",
# "",
# "    # Node1: Encrypt the message",
# "    ciphertext = public_key.encrypt(",
# "        message,",
# "        padding.OAEP(",
# "            mgf=padding.MGF1(algorithm=hashes.SHA256()),",
# "            algorithm=hashes.SHA256(),",
# "            label=None",
# "        )",
# "    )",
# "",
# "    # Node2: Decrypt the message",
# "    plaintext = private_key.decrypt(",
# "        ciphertext,",
# "        padding.OAEP(",
# "            mgf=padding.MGF1(algorithm=hashes.SHA256()),",
# "            algorithm=hashes.SHA256(),",
# "            label=None",
# "        )",
# "    )"


from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import padding

def encrypt_decrypt(message):
    # Node1: Generate a private key
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
    )

    # Node1: Generate the public key
    public_key = private_key.public_key()

    # Node1: Serialize the public key
    pem = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

    # Node2: Load the public key
    public_key = serialization.load_pem_public_key(pem)

    # Node1: Encrypt the message
    ciphertext = public_key.encrypt(
        message,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

    # Node2: Decrypt the message
    plaintext = private_key.decrypt(
        ciphertext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )
    )

    return plaintext

# Usage
message = int(66)
encrypt_decrypt(b'66')
