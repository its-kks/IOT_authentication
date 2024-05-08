function [rand] = Python_random(lower,upper)
python_code = [
    "import random as ran"
    "def rangen(lower,upper):"
    "   return str(ran.randint(lower,upper))"
];

pyrun(python_code);

rand = string(pyrun([strcat("ans = rangen(", num2str(lower),",", num2str(upper) ,")")],"ans"));
end
