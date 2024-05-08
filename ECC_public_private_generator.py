from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import ec
import random as ran

q = 115792089210356248762697446949407573529996955224135760342422259061068512044369 # prime number
G = {"x":48439561293906451759052585252797914202762949526041747995844080717082404635286, "y":36134250956749795798585127919587881956611106672985015071877198253568414405109}
order = 0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551
cofactor = 1
A = 0xFFFFFFFF00000001000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFC
B = 0x5AC635D8AA3A93E7B3EBBD55769886BC651D06B0CC53B0F63BCE3C3E27D2604B


def n_P(n):
    private_key = ec.derive_private_key(n, ec.SECP256R1(), default_backend())
    public_key = private_key.public_key()
    public_numbers = public_key.public_numbers()
    return {"x":public_numbers.x,"y":public_numbers.y}

x  = ran.randint(100000,10000000000000000000000) # private key

Pub = n_P(55) # public key

print(Pub)

# print(Pub,x,G,q,sep="\n")

