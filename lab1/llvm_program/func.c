// 编写函数，用llvm写函数调用
float func(int a,float b){
    float c=a+b;
    return c;
}

int main(){
    int a=1;
    float b[2];
    b[0]=1.5;
    b[1]=func(a,b[0]);
}
