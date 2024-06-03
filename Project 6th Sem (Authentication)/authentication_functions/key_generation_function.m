function [x_dash,y_dash] = key_generation_function(x,y)
% This is the KDF (Key derivation function)

    python_code = [
    "import hashlib"
    ""
    "def key_generation_function(x, y):"
    "    # Create a new hashlib sha256 object"
    "    sha256 = hashlib.sha256()"
    ""
    "    sha256.update(str(x).encode('utf-8'))"
    "    x_prime = int(sha256.hexdigest(), 16)"
    ""
    "    sha256.update(str(y).encode('utf-8'))"
    "    y_prime = int(sha256.hexdigest(), 16)"
    ""
    "    return ([x_prime, y_prime])"
    ];

    pyrun(python_code);
    Pub = pyrun(strcat("ans = key_generation_function(" , num2str(x) , ...
        ",",num2str(y),")"),"ans");
    % Coordinates of Public Key being generated
    x_dash = string(Pub(1));
    y_dash = string(Pub(2));
end
