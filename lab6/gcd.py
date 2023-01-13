

def gcd(a, b):
    if (b == 0):
        return a
    else:
        return gcd(b, a % b)
        
c = gcd(25, 15)
print(c)