%{
/*********************************************
YACC file
基础程序
Date:2023/9/30
修改程序，生成汇编代码
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
// 符号表操作函数声明
struct symbol* findSymbol(char* name);
void addSymbol(char* name, double value);

#define MAX_NAME_LEN 20
// 符号表
struct symbol{
    char *name;
    double value;
    struct symbol *next;
};
// 头指针
struct symbol *symbolTable = NULL;


%}

%union{
    int dval;  // 变量值 -> 改成int 简化汇编代码
    char *name;   // 变量名
}

// 给每个符号定义一个单词类别
%token<dval> NUMBER
%token ADD MINUS
%token MUL DIV
%token LPAREN RPAREN
%token QUIT // 退出程序
%token<name> IDENTIFIER // 标识符
%token ASSIGN // 赋值符号

%left ASSIGN
%left ADD MINUS
%left MUL DIV
%right UMINUS   


// 还得给非终结符定义类型
%type<dval> expr
%type<dval> stmt
%start lines

%%

// 使用;作为一行的结束符
lines   :       lines stmt ';' { printf("----------\n"); }
        |       lines ';'
        |       lines QUIT  { exit(0); }
        |
        ;
// 语句     
stmt    :       expr  { $$=$1; }
        |       IDENTIFIER ASSIGN expr  {    $$=$3;
                                            addSymbol($1,$3);  // 添加到符号表
                                            printf("ldr R1, =%s\n",$1);
                                            printf("str R0, [r1]\n");
                                        }
        ;
// 完善表达式的规则
expr    :       expr ADD expr   {   $$=$1+$3; 
                                    printf("MOV R0 %d\n",$1);
                                    printf("MOV R1 %d\n",$3);
                                    printf("ADD R0 R0 R1\n");
                                }
        |       expr MINUS expr {   $$=$1-$3;
                                    printf("MOV R0 %d\n",$1);
                                    printf("MOV R1 %d\n",$3);
                                    printf("SUB R0 R0 R1\n");
                                }
        |       expr MUL expr   {   $$=$1*$3;
                                    printf("MOV R0 %d\n",$1);
                                    printf("MOV R1 %d\n",$3);
                                    printf("MUL R0 R0 R1\n"); 
                                }
        |       expr DIV expr   {   $$=$1/$3; 
                                    printf("MOV R0 %d\n",$1);
                                    printf("MOV R1 %d\n",$3);
                                    printf("DIV R0 R0 R1\n");
                                }
        |       LPAREN expr RPAREN   { $$=$2; }
        |       MINUS expr %prec UMINUS   {$$=-$2;}  // %prec提升优先级
        |       NUMBER  {$$=$1;}
        |       IDENTIFIER  {   struct symbol *entry=findSymbol($1);
                                if(entry==NULL){
                                    yyerror("undeclared variable");
                                }
                                $$=entry->value;
                                printf("ldr R0, [%s]\n",$1);
                            }
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
            yylval.dval = 0;  // yylval存储和传递词法单元的值
            while(isdigit(t)){
                yylval.dval = yylval.dval * 10 + (t - '0');
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
        else if(t=='='){  // 赋值符号
            return ASSIGN;
        }
        else if(isalpha(t)){  // 识别标识符
            char *p = yylval.name = malloc(MAX_NAME_LEN);
            *p++ = t;
            int len = 1;
            // 读取标识符
            while(isalnum(t=getchar())){
                *p++ = t;
                if(++len>=MAX_NAME_LEN){
                    yyerror("name too long");
                }
            }
            ungetc(t,stdin);  // 将多读的字符放回缓冲区
            *p = '\0';  // 字符串结束符
            return IDENTIFIER;
        }
        else if(t=='#'){  // 退出程序
            return QUIT;
        }
        else{  // ;
            return t;
        }
    }
}

struct symbol* findSymbol(char* name){
    // 在符号表中查找一个符号
    struct symbol *s;
    for(s=symbolTable;s!=NULL;s=s->next){  // 遍历符号表
        if(strcmp(s->name,name)==0){
            return s;
        }
    }
    return NULL;  // 没有找到
}

void addSymbol(char* name, double value){
    // 向符号表中添加一个符号
    struct symbol *s = findSymbol(name);
    if(s!=NULL){  // 如果已经存在
        s->value = value;
        return;
    }
    // 否则创建一个新的符号
    s = malloc(sizeof(struct symbol));
    s->name = strdup(name);
    s->value = value;
    s->next = symbolTable;
    symbolTable = s;
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