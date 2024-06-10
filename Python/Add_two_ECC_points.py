import tinyec.ec as ec

def add_points(x1,y1,x2,y2):
    # curve used is SECP256R1
    p  = 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff # prime number
    a = 0xffffffff00000001000000000000000000000000fffffffffffffffffffffffc # a in y^2 = x^3 + ax + b
    b = 0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b # b in y^2 = x^3 + ax + b
    x = 0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296 # x coordiante of generator point
    y = 0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5 # y coordiante of generator point
    o = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551 # order of field
    c = 0x1 # co-factor of field

    g = (x, y)  # generator point
    field = ec.SubGroup(p, g, n=o, h=c)
    curve = ec.Curve(a, b, field)

    p1 = ec.Point(curve=curve,x = x1,y=y1)
    p2 = ec.Point(curve=curve,x = x2, y= y2)

    r = p1 + p2

    return [r.x,r.y]

print(add_points(51946802941087205079243810382461768693944312723647194557948352268083710035208,4123937734559666614786074439029579477812688615316221923398072641713764514837,103148717677252002301746836041631896103684038590267492923001500637701159239767,37558545393368213380303721180848612304399030212075113927006727211229809313982))