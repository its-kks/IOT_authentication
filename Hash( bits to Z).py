import hashlib

def H(*args):
    q = 115792089210356248762697446949407573529996955224135760342422259061068512044369
    input_string = ""
    for i in args:
        input_string += str(i)
    input_bytes = input_string.encode()
    hash_bytes = hashlib.sha256(input_bytes).digest()
    hash_int = int.from_bytes(hash_bytes, byteorder='big')
    return hash_int % q

print(H(33,33,88))