import hashlib

def generate_keys(x, y):
    # Create a new hashlib sha256 object
    sha256 = hashlib.sha256()

    # Hash the x coordinate and get the integer result
    sha256.update(str(x).encode('utf-8'))
    x_prime = int(sha256.hexdigest(), 16)

    # Generate a second hash for the x coordinate
    sha256.update(str(x_prime).encode('utf-8'))
    x_prime_dash = int(sha256.hexdigest(), 16)

    # Hash the y coordinate and get the integer result
    sha256.update(str(y).encode('utf-8'))
    y_prime = int(sha256.hexdigest(), 16)

    # Generate a second hash for the y coordinate
    sha256.update(str(y_prime).encode('utf-8'))
    y_prime_dash = int(sha256.hexdigest(), 16)

    return x_prime, x_prime_dash, y_prime, y_prime_dash

# Test the function
x_prime, x_prime_dash, y_prime, y_prime_dash = generate_keys(5, 10)
print(f"x': {x_prime}, x'': {x_prime_dash}, y': {y_prime}, y'': {y_prime_dash}")
