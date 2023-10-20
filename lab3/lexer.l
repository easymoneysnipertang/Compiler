%option noyywrap
%option nounput
%option noinput
%option yylineno

%top{
    #include <stdarg.h>
    #include "common.h"
    #include <unordered_map>
    #include <string>
    #include <malloc.h>
    using namespace std;
}
%{
    extern dump_type_t dump_type;
    extern int yylineno;
    int col = 1;

    inline void dump_tokens(const char* format, ...){
        va_list args;
        va_start(args, format);
        if (dump_type == TOKENS)
            vfprintf(yyout, format, args);
        va_end(args);
    }

    /* Your code here, if desired (lab3). */
    struct entry{  //符号表项
    char name[32];
    //int IVal;  // 还没到语法分析
    //float FVal;
    };

    /* StackEntry类，栈里的元素，记录一个作用域下的所有变量 */
    class StackEntry{
    private:
        unordered_map<string,entry*> map;  // 记录作用域里的变量
        StackEntry* next;  // 指向栈中下一个元素
    public:
        // 构造函数
        StackEntry(){
            next = nullptr;
        }
        // 有参构造函数
        StackEntry(StackEntry* next){
            this->next = next;
        }
        // 析构函数
        ~StackEntry(){
            // 创建一个空的map，释放内存
            unordered_map<string, entry*>().swap(map);
            // 释放内存碎片
            malloc_trim(0);
            next = nullptr;
        }
        // 为一个作用域添加一个变量
        void add(string name, entry* e){
            map[name] = e;
        }
        // 从一个作用域中查找一个变量
        entry* find(string name){
            if(map.empty()){
                return nullptr;
            }
            else{
                auto it = map.find(name);
                if(it == map.end()){
                    return nullptr;
                }
                else{
                    return it->second;
                }
            }
        }
        StackEntry* getNext(){
            return next;
        }
    };

    /* 符号表类 */
    class SymbolTableStack{
    private:
        StackEntry* top;  // 栈顶指针
    public:
        // 构造函数
        SymbolTableStack(){
            // 栈最底层作用域，记录全局变量
            StackEntry* end = new StackEntry();
            top = end;
        }
        // 添加一个作用域
        void push(){
            StackEntry* newTop = new StackEntry(top);
            top = newTop;
        }
        // 出栈
        void pop(){
            if(top == nullptr){
                return;
            }
            else{
                StackEntry* oldTop = top;
                top = top->getNext();
                delete oldTop;
            }
        }
        // 为当前作用域添加一个变量
        void add(string name, entry* e){
            top->add(name, e);
        }
        // 从当前作用域查找一个变量
        entry* find(string name){
            // 从栈顶开始查找
            StackEntry* cur = top;
            while(cur != nullptr){
                entry* e = cur->find(name);
                if(e != nullptr)
                    // 找到了，返回
                    return e;
                else
                    cur = cur->getNext();
            }
            // 没找到，认为是新变量，放到栈顶作用域
            entry* newEntry = new entry();
            strcpy(newEntry->name, name.c_str());
            top->add(name, newEntry);
            return newEntry;
        }
    };
    SymbolTableStack* stack = new SymbolTableStack();
%}

/* definitions section */
/* 浮点数 */
DIGIT_SEQEUNCE [0-9]+
FRACTIONAL_CONSTANT ({DIGIT_SEQEUNCE})\.({DIGIT_SEQEUNCE})?
EXPONENT_PART ([eE][+-]?{DIGIT_SEQEUNCE})
DECIMAL_FLOAT_CONSTANT ({FRACTIONAL_CONSTANT}{EXPONENT_PART}?|{DIGIT_SEQEUNCE}{EXPONENT_PART}?)
HEX_DIGIT [0-9a-fA-F]
HEXADECIMAL_FLOAT_CONSTANT (0[xX]({HEX_DIGIT}+|{HEX_DIGIT}+\.{HEX_DIGIT}*)[pP][+-]?{DIGIT_SEQEUNCE})
FLOAT_CONSTANT ({DECIMAL_FLOAT_CONSTANT}|{HEXADECIMAL_FLOAT_CONSTANT})

/* 整数 */
DECIMIAL ([1-9][0-9]*|0)
HEXADECIMAL 0[xX][a-fA-F0-9]+
OCTAL 0[0-7]+
NUMBER ({HEXADECIMAL}|{DECIMAL}|{OCTAL})

/* 注释 */
%x COMMENT
/* 以双斜杠开头，后跟若干非换行符 */
COMMENT_LINE \/\/[^\n]*
COMMENT_BEGIN \/\*
COMMENT_ELEMENT .|\n
COMMENT_END \*\/

ID [[:alpha:]_][[:alpha:][:digit:]_]*
EOL (\r\n|\n|\r)
WHITE [\t ]


%%
    /* rules section */
"int" {
    dump_tokens("INT\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 3;
}

"void" {
    dump_tokens("VOID\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 4;
}

"if" {
    dump_tokens("IF\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 2;
}

"else" {
    dump_tokens("ELSE\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 4;
}

"return" {
    dump_tokens("RETURN\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 6;
}

"const" {
    dump_tokens("RETURN\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 5;
}

"while" {
    dump_tokens("WHILE\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 5;
}

"break" {
    dump_tokens("BREAK\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 5;
}

"continue" {
    dump_tokens("CONTINUE\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 8;
}

"=" {
    dump_tokens("ASSIGN\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"==" {
    dump_tokens("EQUAL\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 2;
}

"!=" {
    dump_tokens("NOTEQUAL\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 2;
}

"<" {
    dump_tokens("LESS\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"<=" {
    dump_tokens("LESSEQUAL\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 2;
}

">" {
    dump_tokens("GREATER\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

">=" {
    dump_tokens("GREATEREQUAL\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 2;
}

"+" {
    dump_tokens("ADD\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"-" {
    dump_tokens("SUB\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"*" {
    dump_tokens("MUL\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"/" {
    dump_tokens("DIV\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"%" {
    dump_tokens("MOD\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"&&" {
    dump_tokens("AND\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 2;
}

"||" {
    dump_tokens("OR\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 2;
}

"!" {
    dump_tokens("NOT\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

";" {
    dump_tokens("SEMICOLON\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"(" {
    dump_tokens("LPAREN\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

")" {
    dump_tokens("RPAREN\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"[" {
    dump_tokens("LBRACKET\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"]" {
    dump_tokens("RBRACKET\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

"{" {
    dump_tokens("LBRACE\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
    // 新建一个作用域
    stack->push();
}

"}" {
    dump_tokens("RBRACE\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
    // 出栈
    stack->pop();
}

"," {
    dump_tokens("COMMA\t%s\t%d\t%d\n", yytext, yylineno, col);
    col += 1;
}

{DECIMIAL} {
    int decimal;
    decimal = atoi(yytext);
    dump_tokens("DECIMAL\t%s\t%d\t%d\t%d\n", yytext, yylineno, col, decimal);
    col += strlen(yytext);
}

{HEXADECIMAL} {
    int hexadecimal;
    hexadecimal = sscanf(yytext, "%x", &hexadecimal);
    dump_tokens("HEXADECIMAL\t%s\t%d\t%d\t%d\n", yytext, yylineno, col, hexadecimal);
    col += strlen(yytext);
}

{OCTAL} {
    int octal;
    octal = sscanf(yytext, "%o", &octal);
    dump_tokens("OCTAL\t%s\t%d\t%d\t%d\n", yytext, yylineno, col, octal);
    col += strlen(yytext);
}

{ID} {
    string str = yytext;
    entry* e = stack->find(str);
    dump_tokens("ID\t%s\t%d\t%d\t%p\n", yytext, yylineno, col,e);
    col += strlen(yytext);
}

{EOL} {col = 1;}

{WHITE} {col++;}

{FLOAT_CONSTANT} {
    float decimal_float;
    decimal_float = atof(yytext);   // 转为浮点数，一步到位
    dump_tokens("FLOAT_CONST\t%s\t%d\t%d\t%f\n", yytext, yylineno, col, decimal_float);
    col += strlen(yytext);
}

{COMMENT_LINE} {}

{COMMENT_BEGIN} { BEGIN(COMMENT); }

<COMMENT>{COMMENT_ELEMENT} {}

<COMMENT>{COMMENT_END} { BEGIN(INITIAL); }


%%
/* user code section */
