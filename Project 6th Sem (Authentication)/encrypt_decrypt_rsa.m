function [processing_time] = encrypt_decrypt_rsa(message)
py_code = [
"from cryptography.hazmat.primitives import serialization"
"from cryptography.hazmat.primitives.asymmetric import rsa"
"from cryptography.hazmat.primitives import hashes"
"from cryptography.hazmat.primitives.asymmetric import padding"
"def encrypt_decrypt(message):"
"    # Node1: Generate a private key"
"    private_key = rsa.generate_private_key("
"        public_exponent=65537,"
"        key_size=2048,"
"    )"
""
"    # Node1: Generate the public key"
"    public_key = private_key.public_key()"
""
"    # Node1: Serialize the public key"
"    pem = public_key.public_bytes("
"        encoding=serialization.Encoding.PEM,"
"        format=serialization.PublicFormat.SubjectPublicKeyInfo"
"    )"
""
"    # Node2: Load the public key"
"    public_key = serialization.load_pem_public_key(pem)"
""
"    # Node1: Encrypt the message"
"    ciphertext = public_key.encrypt("
"        message,"
"        padding.OAEP("
"            mgf=padding.MGF1(algorithm=hashes.SHA256()),"
"            algorithm=hashes.SHA256(),"
"            label=None"
"        )"
"    )"
""
"    # Node2: Decrypt the message"
"    plaintext = private_key.decrypt("
"        ciphertext,"
"        padding.OAEP("
"            mgf=padding.MGF1(algorithm=hashes.SHA256()),"
"            algorithm=hashes.SHA256(),"
"            label=None"
"        )"
"    )"
""
"    return plaintext"
];

pyrun(py_code)

encrypt_decrypt = tic;


fun_call = strcat("encrypt_decrypt(b'",message,"')");
pyrun(fun_call);

processing_time = toc(encrypt_decrypt);
end

