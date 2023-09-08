#include<stdio.h>
#define n 3

void do_while(int i,int f){
    while(i<=n){
        f=f*i;// 累乘计算
        i=i+1;
    }
}

int main(){
    int i,f;
    i=2;// 初始化循环计数器
    f=1;
    do_while(i,f);
}