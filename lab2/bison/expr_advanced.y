%{
/*********************************************
YACC file
基础程序
Date:2023/9/29
表达式进阶，为每个标识符设置单词类别，增强词法分析
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>

#ifndef YYSTYPE
#define YYSTYPE double
#endif

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

// 给每个符号定义一个单词类别
%token NUMBER
%token ADD MINUS
%token MUL DIV
%token LPAREN RPAREN
%token QUIT // 退出程序

%left ADD MINUS
%left MUL DIV
%right UMINUS         

%%

// 使用;作为一行的结束符
lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |       lines QUIT  { exit(0); }
        |
        ;
// 完善表达式的规则
expr    :       expr ADD expr   { $$=$1+$3; }
        |       expr MINUS expr   { $$=$1-$3; }
        |       expr MUL expr   { $$=$1*$3; }
        |       expr DIV expr   { $$=$1/$3; }
        |       LPAREN expr RPAREN   { $$=$2; }
        |       MINUS expr %prec UMINUS   {$$=-$2;}  // %prec提升优先级
        |       NUMBER  {$$=$1;}
        ;

%%

// programs section

int yylex()  // 词法分析器
{
    int t;
    while(1){
        t = getchar();
        if(t==' '||t=='\t'||t=='\n'){  // 忽略空白符
            // do noting
        }
        else if(isdigit(t)){
            // 解析多位数字返回数字类型 
            yylval = 0;  // yylval存储和传递词法单元的值
            while(isdigit(t)){
                yylval = yylval * 10 + (t - '0');
                t = getchar();
            }
            // 将读出的多余字符再次放回到缓冲区去
            ungetc(t,stdin);
            return NUMBER;
        }
        else if(t=='+'){
            return ADD;
        }
        else if(t=='-'){
            return MINUS;
        }
        else if(t=='*'){
            return MUL;
        }
        else if(t=='/'){
            return DIV;
        }
        else if(t=='('){
            return LPAREN;
        }
        else if(t==')'){
            return RPAREN;
        }
        else if(t=='q'){  // 退出程序
            return QUIT;
        }
        else{  // ;
            return t;
        }
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}