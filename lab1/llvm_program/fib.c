#include<stdio.h>

// 计算斐波拉契数列
int main(){
    int a,b,i,t,n;
    a=0;b=1;i=1;
    scanf("%d",&n);
    printf("%d\n%d\n",a,b);
    while (i<n)
    {
        t=b;
        b=a+b;
        printf("%d\n",b);
        a=t;
        i=i+1;
    }
    
}