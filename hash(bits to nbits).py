import hashlib

def h(input_string, n):
    # Convert the input string to bytes
    input_bytes = input_string.encode()

    # Generate the hash bytes
    hash_bytes = hashlib.sha256(input_bytes).digest()

    # Convert the hash bytes to binary
    hash_binary = bin(int.from_bytes(hash_bytes, byteorder='big'))[2:]

    # Return the first n bits of the binary hash
    return hash_binary[:n]

print(h(str(345323454343),1000))