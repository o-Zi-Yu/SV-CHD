int greet(int n) {
if (n <= 1)
return 1;
else
return (n+greet(n-1));
}