function [hashed_value] = Hash_bits_to_Z(varargin)
%HASH_BITS_TO_Z converts {0,1}* to Z over q
    python_code = [
    "import hashlib",
    "def H(*args):",
    "   q = 115792089210356248762697446949407573529996955224135760342422259061068512044369",
    "   input_string = ''",
    "   for i in args:",
    "       input_string += str(i)",
    "   input_bytes = input_string.encode()",
    "   hash_bytes = hashlib.sha256(input_bytes).digest()",
    "   hash_int = int.from_bytes(hash_bytes, byteorder='big')",
    "   return str(hash_int % q)"
];

pyrun(python_code);

func_call = "ans = H(";
for k = 1:nargin
    func_call = func_call + varargin{k};
    if k ~= nargin
        func_call = func_call + ",";
    end
end

func_call = func_call + ")";

hashed_value = string(pyrun(func_call,"ans"));

end

