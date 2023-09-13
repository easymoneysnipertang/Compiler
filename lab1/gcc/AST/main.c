#include<stdio.h>
int main(){
    int i,n,f;
    scanf("%d",&n);// 接收输入
    i=2;// 初始化循环计数器
    f=1;
    while(i<=n){
        f=f*i;// 累乘计算
        i=i+1;
    }
    printf("%d\n",f);
}


// int main(){
//     int i,n,f;
//     n=2;
//     i=2;// 初始化循环计数器
//     f=1;
//     while(i<=n){
//         f=f*i;// 累乘计算
//         i=i+1;
//     }
// }
