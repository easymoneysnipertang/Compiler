define float @func(i32 %1,float %2){
    %3 = alloca float, align 4      ; 定义float c
    %4 = load i32, i32* %1, align 4 ; 操作前取值
    %5 = load float, float* %2, align 4
    %6 = sitofp i32 %4 to float     ; 类型转换
    %7 = fadd float %6, %5          ; 相加
    store %5 float* %3 align 4      ; 存入c
    ret float %3                    ; 返回
}

define i32 @main(){
    %1 = alloca i32,align 4         ; 定义a
    store i32 1, i32* %1, align 4   ; 赋值
    %2 = alloca [2 x float], align 4; 定义数组
    ; 取出数组，赋值
    %3 = getelementptr inbounds [2 x float], [2 x float]* @2, i32 0, i32 0
    store float 1.5, float* %3, align 4
    ; 取出值做参数
    %4 = load i32, i32* %1, align 4
    %5 = getelementptr inbounds [2 x float], [2 x float]* @2, i32 0, i32 0
    ; 调用函数，赋值
    %6 = call float @func(i32 %4,float %5)
    %7 = getelementptr inbounds [2 x float], [2 x float]* @2, i32 0, i32 1
    store float %6, float* %7, align4
    ret i32 0
}