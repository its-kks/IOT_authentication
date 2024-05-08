function [Pub_x,Pub_y] = ECC_x_dot_P_new(x,varargin)
% This function generates Public Key using private key X
% ECC algorithm used is SECP256R1

    python_code = [
    "import tinyec.ec as ec"
    ""
    "# curve used is SECP256R1"
    ""
    "def find_public_key(private_key, gen_x=0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296, gen_y=0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5):"
    "    p  = 0xffffffff00000001000000000000000000000000ffffffffffffffffffffffff # prime number"
    "    a = 0xffffffff00000001000000000000000000000000fffffffffffffffffffffffc # a in y^2 = x^3 + ax + b"
    "    b = 0x5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b # b in y^2 = x^3 + ax + b"
    "    # x = 0x6b17d1f2e12c4247f8bce6e563a440f277037d812deb33a0f4a13945d898c296 # x coordiante of generator point"
    "    # y = 0x4fe342e2fe1a7f9b8ee7eb4a7c0f9e162bce33576b315ececbb6406837bf51f5 # y coordiante of generator point"
    "    o = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551 # order of field"
    "    c = 0x1 # co-factor of field"
    ""
    "    field = ec.SubGroup(p, (gen_x, gen_y), o, c)"
    "    curve =ec.Curve(a, b, field)"
    "    G = ec.Point(curve, gen_x, gen_y)"
    ""
    "    public_key = private_key * G"
    ""
    "    return([public_key.x,public_key.y])"
    ];

    if nargin > 1
        pyrun(python_code);
        Pub = pyrun(strcat("ans = find_public_key(" , num2str(x) , "," , varargin{1} , "," , varargin{2},")"),"ans");
        
        % Coordinates of Public Key being generated
        Pub_x = string(Pub(1));
        Pub_y = string(Pub(2));
    else
        pyrun(python_code);
        Pub = pyrun("ans = find_public_key(" + num2str(x) + ")","ans");
        
        % Coordinates of Public Key being generated
        Pub_x = string(Pub(1));
        Pub_y = string(Pub(2));
    end
end
