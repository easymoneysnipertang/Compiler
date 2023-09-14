#include<stdio.h>
#include<sys/time.h>

int main(){
    int i,n;
    struct  timeval  start;
    struct  timeval  end;
    unsigned long timer,f;
    for(int j=1;j<=5;j++){
        gettimeofday(&start,NULL);
        
        n=1000000*j;
        i=2;// 初始化循环计数器
        f=1;
        while(i<=n){
            f=f*i;// 累乘计算
            i=i+1;
        }

        gettimeofday(&end,NULL);
        timer = 1000000 * (end.tv_sec-start.tv_sec)+ end.tv_usec-start.tv_usec;
        printf("timer = %ld us\n",timer);
        printf("%ld\n",f);// 防止把f给我优化掉了
    }
}