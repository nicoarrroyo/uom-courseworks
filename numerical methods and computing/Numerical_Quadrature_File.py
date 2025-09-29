import numpy as np

a = float(input("value of lower limit 'a': "))
b = float(input("value of upper limit 'b': "))
choice = input("type 'trapezoidal' or 'simpson' to choose your method: ")
valid = False
x = np.array(np.linspace(a, b))
I_exact = 1/8
n_s = 4
h = np.array(np.linspace(a, b, n_s+1))

# integrand function f(x)
def f(x): return (x)

# numerical integration methods function definitions
def trapezoidal(a, b, n_s, h):
    I = 0
    for i in range(0, len(h)-1):
        a = h[i]
        b = h[i+1]
        I += ((b-a)/2) * (f(a) + f(b))
    return I
def simpson(a, b, n_s, h):
    I = 0
    for i in range(0, len(h)-1):
        a = h[i]
        b = h[i+1]
        I += ((b-a)/6) * (f(a) + (4*f((a+b)/2)) + f(b))
    return I

# while loop to check for valid method choice from user
while (not valid):
    if (choice == "trapezoidal"):
        valid = True
        result = trapezoidal(a, b, n_s, h)
    elif (choice == 'simpson'):
        valid = True
        result = simpson(a, b, n_s, h)
    else:
        valid = False
        choice = input("please type either 'trapezoidal' or 'simpson': ")

print(choice, "integration result:", result)
print("hand-calculated exact result:", I_exact)
print(choice, "integration error:", abs(I_exact - result))