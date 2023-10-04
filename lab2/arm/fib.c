#include<stdio.h>

int n;
int fib(int n) {
    if (n <= 1) {
        return 1;
    } else {
        return fib(n-1) + fib(n-2);
    }
}

int main() {
    scanf("%d", &n);
    int result = fib(n);
    printf("fib(%d) = %d\n", n, result);
    return 0;
}


