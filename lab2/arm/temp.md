# TODO
1. 分工SysY特性，编写CFG
2. 设计Sysy程序，手工编写ARM汇编，生成可执行文件验证
3. 设计语法指导，利用Bison实现SysY到汇编的翻译


# 参考链接
CFG设计参考:   
https://buaa-se-compiling.github.io/miniSysY-tutorial/miniSysY.html  
arm汇编基础:   
https://blog.csdn.net/weixin_45309916/article/details/107837561  
Bision参考:   
https://blog.csdn.net/weixin_44007632/article/details/108666375  
https://zhuanlan.zhihu.com/p/111445997

# 编译指令
```bash
arm-linux-gnueabihf-gcc -o fib.s -S -O0 fib.c
arm-linux-gnueabihf-gcc fib.s -o fib.out
qemu-arm -L /usr/arm-linux-gnueabihf ./fib.out
```
