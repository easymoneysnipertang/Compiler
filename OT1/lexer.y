%{
/*********************************************
YACC file
可以用C++写！！！
1. 实现Thompson构造法，从正则表达式转NFA(finish date:2023/10/20)
2. 实现子集构造法，从NFA转DFA(finish date:2023/10/22)
3. 实现DFA的最小化(finish date:)
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#include<stdbool.h>

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);

// 操作符号表
struct symbol* findSymbol(char c);
void addSymbol(char c);
void cleanSymbolTable();

// 实现Thompson构造法
struct State* newState(int edgeNum);
void addEdge(struct State* begin,struct State* end,char c);
struct NFA* newNFA(char c);
struct NFA* closureNFA(struct NFA* nfa);
struct NFA* connectNFA(struct NFA* nfa1,struct NFA* nfa2);
struct NFA* orNFA(struct NFA* nfa1,struct NFA* nfa2);
void printNFA(struct NFA* nfa);
void dumpNFA(struct NFA* nfa);

// 子集构造法，从NFA转DFA
void testSet(struct State* t,int num);
struct State* copyState(struct State* s);
int epsilonClosure(struct State* T_begin,struct State* T_end,bool* isAccept);
struct DFA* NFA2DFA(struct NFA* nfa);
struct State* move(struct State* T_begin,char c,int T_num,struct State** DestEnd);
struct DFAState* newDFAState(int edgeNum);
void addDFAEdge(struct DFAState* begin,struct DFAState* end,char c);
struct DFAState* isExist(struct DFAState* queueFront,int totalStateNum,struct DFAState* check);
void dumpDFA(struct DFA* dfa);

// 最小化DFA
int initGroupSet(struct DFAState* groupSet,struct DFAState* queueFront);
void testGroup(struct DFAState* groupSet,int groupNum);
int makeAMove(struct DFAState* s,char c);
int divideGroup(struct DFAState* groupSet,struct DFAState* groupPtr,int nowGroupNum);
struct DFAState* getTheGroup(struct DFAState* start,int groupNum,int groupLabel);
struct DFA* minimizeDFA(struct DFA* dfa);
void dumpMinDFA(struct DFA* dfa);



// 符号表
struct symbol{
    char c;
    struct symbol *next;
};
// 头指针
struct symbol *symbolTable = NULL;
int totalSymbolNum = 0;  // 符号表中符号的数量

#define none '$'  // 空串
int FILE_NUM = 0;  // 一行一个文件

// NFA
int nfa_accept_id;  // nfa接收状态的id
int nfa_state_num;  // nfa总状态数

struct Edge{  // NFA的一条边
    char c;  // 边上的字符
    struct State* next;  // 边指向的下一个状态
};
struct State{  // NFA的一个状态
    int id;  // 状态编号
    //int isend;  // 是否是终态，倒不需要这来记，就一个终态
    struct Edge edgeOut[3];  // 状态的出边，最多两条，第三条给队列用
    int edgeNum;  // 出边的数量，<=2，重要状态
    bool visited;  // 是否访问过，遍历的时候有环
};
struct NFA{  // NFA由一连串的状态和边组成
    struct State* start;  // 开始状态
    struct State* end;  // 结束状态
};

// DFA
struct DFAEdge{  // DFA的一条边
    char c;  // 边上的字符
    struct DFAState* next;  // 边指向的下一个状态
    struct DFAEdge* nextEdge;  // 下一条边
};
struct DFAState{  // DFA的一个状态
    int id;  // 状态编号
    struct State* nfaState;  // 对应的NFA状态
    int nfaStateNum;  // 对应的NFA状态的数量，最小化的时候复用，作为分组标签
    struct DFAEdge* edgeOut;  // 状态的出边，是一个链表，第一条边负责串接队列
    int edgeNum;  // 出边的数量
    bool isAccept;  // 是否是接收状态
};
struct DFA{
    struct DFAState* start;  // 开始状态
    //struct DFAState* end;  // 结束状态
};



%}

%union{
    char cval;  // 字符
    struct NFA* nval;  // 控制NFA
}

// 单词类别
%token OR
%token CLOSURE
%token LBRACE
%token RBRACE
%token QUIT
%token <cval> CHAR

// 结合律和优先级
%left OR
%left CONNECT
%left CLOSURE

// 非终结符
%type <nval> expr
%type <nval> term_connect
%type <nval> term
%start lines

%%
// 规则
lines   :       lines expr ';' {    nfa_state_num=0; 
                                    dumpNFA($2);   // 输出到dot文件
                                    printf("----dump NFA----\n");
                                    
                                    struct DFA* dfa = NFA2DFA($2);  // 子集构造法
                                    dumpDFA(dfa);  // 输出到dot文件
                                    printf("----dump DFA----\n");

                                    struct DFA* min_dfa = minimizeDFA(dfa);  // 最小化DFA
                                    //dumpMinDFA(min_dfa);  // 输出到dot文件
                                    printf("----minimize DFA----\n");

                                    cleanSymbolTable();  // 清空符号表
                                    FILE_NUM++;
                                    printf("------------------\n"); 
                                }
        |       lines ';'
        |       lines QUIT  { exit(0); }
        |
        ;
expr    :       expr OR term_connect { $$ = orNFA($1,$3); }  // 或
        |       term_connect { $$ = $1; }
        ;
term_connect    :       term term_connect { $$ = connectNFA($1,$2); }  // 连接
        |       term { $$ = $1; }
        ;
term    :       term CLOSURE { $$ = closureNFA($1); }  // 闭包
        |       LBRACE expr RBRACE { $$ = $2; }
        |       CHAR {  $$ = newNFA($1); 
                        addSymbol($1);  // 添加到符号表   
                    }  // 新建一个NFA
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
        else if(t=='|'){
            return OR;
        }
        else if(t=='*'){
            return CLOSURE;
        }
        else if(t=='('){
            return LBRACE;
        }
        else if(t==')'){
            return RBRACE;
        }
        else if(t=='#'){
            return QUIT;
        }
        else if(t==';')
            return t;
        else{
            yylval.cval = t;
            return CHAR;
        }
    }
}


// 操作符号表
struct symbol* findSymbol(char c){
    // 在符号表中查找一个符号
    struct symbol *s;
    for(s=symbolTable;s!=NULL;s=s->next)  // 遍历符号表
        if(c==s->c){
            return s;
        }
    return NULL;  // 没有找到
}

void addSymbol(char c){
    // 向符号表中添加一个符号
    struct symbol *s = findSymbol(c);
    if(s!=NULL||c==none)  // 如果已经存在
        return;
    // 否则创建一个新的符号
    s = malloc(sizeof(struct symbol));
    s->c = c;
    s->next = symbolTable;
    symbolTable = s;
    totalSymbolNum++;
}

void cleanSymbolTable(){
    // 清空符号表
    struct symbol *s;
    for(int i=0;i<totalSymbolNum;i++){
        s = symbolTable->next;
        free(symbolTable);
        symbolTable = s;
    }
    symbolTable = NULL;
    totalSymbolNum = 0;
}


// 实现Thompson构造法，从正则表达式转NFA
struct State* newState(int edgeNum){  // 辅助函数
    // 生成一个新的状态
    struct State* s = (struct State*)malloc(sizeof(struct State));
    s->edgeNum = edgeNum;
    s->visited = false;
    return s;
}

void addEdge(struct State* begin,struct State* end,char c){  // 辅助函数
    struct Edge e;
    e.c = c;
    e.next = end;
    // 在begin后添加边
    begin->edgeOut[begin->edgeNum++] = e;
}

struct NFA* newNFA(char c){  // 处理单个字符
    // 生成一个新的NFA
    struct NFA* nfa = (struct NFA*)malloc(sizeof(struct NFA));
    // 开始状态，结束状态
    struct State* start = newState(0); 
    struct State* end = newState(0);
    // 添加一条边
    addEdge(start,end,c);
    // 添加start和end
    nfa->start = start;
    nfa->end = end;
    return nfa;
}

struct NFA* closureNFA(struct NFA* nfa){  // 处理闭包
    struct State* start = newState(0); 
    struct State* end = newState(0);
    // 添加边，顺序挺重要，不然后续ID很奇怪
    addEdge(start,nfa->start,none);
    addEdge(start,end,none);
    addEdge(nfa->end,end,none);
    addEdge(nfa->end,nfa->start,none);
    // 添加start和end
    nfa->start = start;
    nfa->end = end;
    return nfa;
}

struct NFA* connectNFA(struct NFA* nfa1,struct NFA* nfa2){  // 处理连接
    // 连接nfa1和nfa2
    //addEdge(nfa1->end,nfa2->start,none);
    for(int i=0;i<nfa2->start->edgeNum;i++){  // 首尾重叠
        nfa1->end->edgeOut[nfa1->end->edgeNum++] = nfa2->start->edgeOut[i];
    }
    nfa1->end = nfa2->end;
    // 释放nfa2
    free(nfa2->start);  // nfa2的start节点不需要了
    free(nfa2);
    return nfa1;
}

struct NFA* orNFA(struct NFA* nfa1,struct NFA* nfa2){  // 处理或
    struct State* start = newState(0); 
    struct State* end = newState(0);
    // 添加边
    addEdge(start,nfa1->start,none);
    addEdge(start,nfa2->start,none);
    addEdge(nfa1->end,end,none);
    addEdge(nfa2->end,end,none);
    // 添加start和end
    nfa1->start = start;
    nfa1->end = end;
    // 释放nfa2
    free(nfa2);
    return nfa1;
}

void printNFA(struct NFA* nfa){  // 打印NFA，调试用
    int id = 0;  // 最后为每个状态编号
    // 还得自己写个队列，没有list.h
    struct State* queueFront,*queueRear;
    // 初始化队列
    queueFront = queueRear = nfa->start;
    queueFront->id = id++;
    queueFront->visited = true;
    while(queueFront!=NULL){  // 队列不为空
        for(int i=0;i<queueFront->edgeNum;i++){  // BFS遍历出边
            if(queueFront->edgeOut[i].next->visited==false){  // 没有访问过，入队
                // 连接到队列尾
                queueRear->edgeOut[2].next = queueFront->edgeOut[i].next;
                queueRear = queueRear->edgeOut[2].next;
                queueRear->id = id++;  // 状态编号
                queueRear->edgeOut[2].next = NULL;  // 队列尾的下一个置空
                queueRear->visited = true;  // 进队列就代表访问过了，不重复进
            }
            // 打印状态图
            printf("State%d -%c-> State%d\n",queueFront->id,queueFront->edgeOut[i].c,queueFront->edgeOut[i].next->id);
        }
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut[2].next;
    }
    printf("total State num: %d\n",id);
    // 释放队列
    struct State* freelist = nfa->start;
    for(int i=0;i<id;i++){
        struct State* temp = freelist->edgeOut[2].next;
        free(freelist);
        freelist = temp;
    }
}

void dumpNFA(struct NFA* nfa){  // 输出到dot文件
    char filename[20];
    sprintf(filename,"NFA%d.dot",FILE_NUM);
    FILE *fp = fopen(filename, "w");
    if (fp == NULL){
        printf("error opening file\n");
        exit(-1);
    }
    fprintf(fp,"digraph G {\n");

    int id = 0;  // 最后为每个状态编号
    // 还得自己写个队列，没有list.h
    struct State* queueFront,*queueRear;
    // 初始化队列
    queueFront = queueRear = nfa->start;
    queueFront->id = id++;
    queueFront->visited = true;
    while(queueFront!=NULL){  // 队列不为空
        for(int i=0;i<queueFront->edgeNum;i++){  // BFS遍历出边
            if(queueFront->edgeOut[i].next->visited==false){  // 没有访问过，入队
                // 连接到队列尾
                queueRear->edgeOut[2].next = queueFront->edgeOut[i].next;
                queueRear = queueRear->edgeOut[2].next;
                queueRear->edgeOut[2].next = NULL;  // 队列尾的下一个置空
                queueRear->visited = true;  // 进队列就代表访问过了，不重复进
                
                queueRear->id = id++;  // 状态编号
                if(queueRear->edgeNum==0)  // 接收状态
                    nfa_accept_id = queueRear->id;
            }
            // 打印状态图
            fprintf(fp,"\t%d -> %d [label=\"%c\"];\n",queueFront->id,queueFront->edgeOut[i].next->id,queueFront->edgeOut[i].c);
        }
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut[2].next;
    }
    // 打印接收状态
    fprintf(fp,"\t%d [shape=doublecircle];\n",nfa_accept_id);
    fprintf(fp,"}\n");
    fclose(fp);
    // 不释放队列，后续转DFA接着用
    nfa_state_num = id;  // 记录nfa总状态数
}


// 子集构造法，从NFA转DFA
void testSet(struct State* t,int num){
    printf("testSet: ");
    for(int i=0;i<num;i++){
        printf("%d ",t->id);
        t = t->edgeOut[2].next;
    }
    printf("\n");
}

// 应该开辟nfa状态，一个nfa状态可能会属于多个dfa状态，多个字符就会错
struct State* copyState(struct State* s){  // 辅助函数
    // 复制一个状态
    struct State* copy = newState(s->edgeNum);
    copy->id = s->id;
    copy->visited = s->visited;
    for(int i=0;i<s->edgeNum;i++){
        copy->edgeOut[i] = s->edgeOut[i];
    }
    return copy;
}

int epsilonClosure(struct State* T_begin,struct State* T_end,bool* isAccept){  // 求闭包
    // 从T出发，经过空串能到达的状态集合
    bool* visited = (bool*)malloc(sizeof(bool)*nfa_state_num);  // 记录是否访问过
    int num=1;  // 记录集合中状态的数量
    // 状态链接在state的第三条边上，链表构成集合
    struct State* queueFront,*queueRear;
    // 传入的T是一个集合
    queueFront = queueRear = T_begin;
    if(queueRear->id==nfa_accept_id)  // 接收状态
            *isAccept = true;

    while(queueRear!=T_end){  // 找到T的尾部
        visited[queueRear->id] = true;  // 进队列就代表访问过了，不重复进
        queueRear = queueRear->edgeOut[2].next;
        num++;

        if(queueRear->id==nfa_accept_id)  // 接收状态
            *isAccept = true;
    }
    visited[queueRear->id] = true;  // 尾部不漏

    while(queueFront!=NULL){  // 队列不为空
        for(int i=0;i<queueFront->edgeNum;i++){  // BFS遍历出边
            if(queueFront->edgeOut[i].c==none&&visited[queueFront->edgeOut[i].next->id]==false){  // 没有访问过，入队
                struct State* temp = copyState(queueFront->edgeOut[i].next);  // 涵盖到的状态都会拷贝一份
                // 连接到队列尾
                queueRear->edgeOut[2].next = temp;
                queueRear = queueRear->edgeOut[2].next;
                queueRear->edgeOut[2].next = NULL;  // 队列尾的下一个置空
                visited[queueRear->id] = true;  // 进队列就代表访问过了，不重复进
                num++;

                if(queueRear->id==nfa_accept_id)  // 接收状态
                    *isAccept = true;
            }
        }
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut[2].next;
    }
    free(visited);
    // 返回的链表是有序的，因为我id就是这么给的
    return num;
}

struct State* move(struct State* T_begin,char c,int T_num,struct State** DestEnd){  // move
    // 从T出发，经过c能到达的状态集合
    bool* visited = (bool*)malloc(sizeof(bool)*nfa_state_num);  // 记录是否访问过
    // 状态链接在state的第三条边上，链表构成集合
    struct State* queueFront = T_begin,*DestBegin = NULL,*Dest = NULL;
    // 遍历集合，每个状态执行一个动作
    for(int i=0;i<T_num;i++)
    {
        // 遍历每个状态的出边
        for(int j=0;j<queueFront->edgeNum;j++){
            if(queueFront->edgeOut[j].c==c&&visited[queueFront->edgeOut[j].next->id]==false){  // 找到个符合的边
                if(DestBegin==NULL){  // 第一个
                    struct State* temp = copyState(queueFront->edgeOut[j].next);  // 涵盖到的状态都会拷贝一份
                    DestBegin = Dest = temp;
                }
                else{  // 不是第一个
                    // 连接到队列尾
                    struct State* temp = copyState(queueFront->edgeOut[j].next);  // 涵盖到的状态都会拷贝一份
                    Dest->edgeOut[2].next = temp;
                    Dest = Dest->edgeOut[2].next;
                }
                Dest->edgeOut[2].next = NULL;  // 队列尾的下一个置空
                visited[Dest->id] = true;  // 避免重复进
            }
        }
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut[2].next;
    }
    free(visited);
    *DestEnd = Dest;
    // 有可能一个都没有
    return DestBegin;
}

struct DFAState* newDFAState(int edgeNum){  // 辅助函数
    // 生成一个新的状态
    struct DFAState* s = (struct DFAState*)malloc(sizeof(struct DFAState));
    s->edgeNum = edgeNum;
    s->isAccept = false;
    // 第一条边负责串接队列
    struct DFAEdge* e = (struct DFAEdge*)malloc(sizeof(struct DFAEdge));
    e->next = NULL;
    e->nextEdge = NULL;
    s->edgeOut = e;
    s->edgeNum++;

    return s;
}

void addDFAEdge(struct DFAState* begin,struct DFAState* end,char c){  // 辅助函数
    // DFA边动态分配，用链表连起来，第一条边负责串接队列
    struct DFAEdge* e = (struct DFAEdge*)malloc(sizeof(struct DFAEdge));
    e->c = c;
    e->next = end;
    e->nextEdge = NULL;
    // 链接边到集合中
    struct DFAEdge* temp = begin->edgeOut;
    for(int i=0;i<begin->edgeNum;i++){  // 找到最后一条边
        if(temp->nextEdge==NULL){
            temp->nextEdge = e;
            begin->edgeNum++;
            break;
        }
        temp = temp->nextEdge;
    }
}

struct DFAState* isExist(struct DFAState* queueFront,int totalStateNum,struct DFAState* check){  // 辅助函数
    // 判断状态是否存在
    for(int i=0;i<totalStateNum;i++){
        if(queueFront->nfaStateNum==check->nfaStateNum){
            bool findDFA = true;
            // 遍历DFA的每个NFA状态
            struct State* s1 = queueFront->nfaState;
            struct State* s2 = check->nfaState;
            for(int j=0;j<queueFront->nfaStateNum;j++){
                // 不一定是按顺序的，所以要遍历
                struct State* temp = s2;
                bool findNFA = false;
                for(int k=0;k<check->nfaStateNum;k++){
                    if(s1->id == temp->id){
                        findNFA = true;
                        break;
                    }
                    temp = temp->edgeOut[2].next;
                }
                if(findNFA==false){  // 有一个NFA状态没找到
                    findDFA = false;
                    break;
                }
                s1 = s1->edgeOut[2].next;  // 下一个NFA状态
            }
            if(findDFA)
                return queueFront;
        }
        // 下一个DFA状态
        queueFront = queueFront->edgeOut->next;
    }
    return NULL;
}

struct DFA* NFA2DFA(struct NFA* nfa){  // 子集构造法
    int id = 0;
    struct DFA* dfa = (struct DFA*)malloc(sizeof(struct DFA));
    // 开始状态
    struct DFAState* start = newDFAState(0);
    struct State* nStart = copyState(nfa->start);
    start->nfaStateNum = epsilonClosure(nStart,nStart,&start->isAccept);  // 计算epsilon闭包
    start->nfaState = nStart;
    start->id = id++;  // id直接编号
    dfa->start = start;
    //testSet(start->nfaState,start->nfaStateNum);

    // 初始化队列
    struct DFAState* queueFront,*queueRear;
    queueFront = queueRear = start;
    
    // 遍历每个未标记状态
    while(queueFront!=NULL){
        struct symbol *s = symbolTable;
        // 遍历每个字符
        for(int i=0;i<totalSymbolNum;i++){
            // 从符号表中取出一个字符
            char c = s->c;
            s = s->next;

            // move
            struct State* DestBegin,*Dest=NULL;
            // C语言没有传引用，传指针的指针
            DestBegin = move(queueFront->nfaState, c, queueFront->nfaStateNum, &Dest);
            if(DestBegin==NULL)  // 没有move出去
                continue;
            else{
                //printf("DestBegin: %d\n",DestBegin->id);
                //printf("Dest: %d\n",Dest->id);
                // 创建新状态
                struct DFAState* DestState = newDFAState(0);
                // 计算epsilon闭包
                DestState->nfaStateNum = epsilonClosure(DestBegin,Dest,&DestState->isAccept);
                DestState->nfaState = DestBegin;
                //testSet(DestState->nfaState,DestState->nfaStateNum);

                // 判断是否已经存在该状态
                struct DFAState* temp = isExist(dfa->start,id,DestState);
                if(temp == NULL){  // 不存在
                    //printf("new state\n");
                    DestState->id = id++;
                    // 添加到队列
                    queueRear->edgeOut->next = DestState;
                    queueRear = queueRear->edgeOut->next;

                    // 添加边
                    addDFAEdge(queueFront,queueRear,c);
                }
                else{  // 存在
                    //printf("exist state\n");
                    // 释放新状态
                    free(DestState->edgeOut);
                    free(DestState);
                    // 添加边
                    addDFAEdge(queueFront,temp,c);
                }
            }
        }
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut->next;
    }

    // 释放nfa队列
    struct State* freelist = nfa->start;
    for(int i=0;i<id;i++){
        struct State* temp = freelist->edgeOut[2].next;
        free(freelist);
        freelist = temp;
    }

    return dfa;
}

void dumpDFA(struct DFA* dfa){  // 输出到dot文件
    char filename[20];
    sprintf(filename,"DFA%d.dot",FILE_NUM);
    FILE *fp = fopen(filename, "w");
    if (fp == NULL){
        printf("error opening file\n");
        exit(-1);
    }
    fprintf(fp,"digraph G {\n");

    struct DFAState* queueFront;
    struct DFAEdge* edgePtr;
    // 初始化队列
    queueFront = dfa->start;

    while(queueFront!=NULL){  // 队列不为空
        edgePtr = queueFront->edgeOut->nextEdge;  // 第一条边负责串接队列
        for(int i=1;i<queueFront->edgeNum;i++){  // BFS遍历出边
            // 打印状态图
            fprintf(fp,"\t%d -> %d [label=\"%c\"];\n",queueFront->id,edgePtr->next->id,edgePtr->c);
            edgePtr = edgePtr->nextEdge;
        }
        // 打印接收状态
        if(queueFront->isAccept)
            fprintf(fp,"\t%d [shape=doublecircle];\n",queueFront->id);
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut->next;
    }

    fprintf(fp,"}\n");
    fclose(fp);
}


// 最小化DFA
int initGroupSet(struct DFAState* groupSet,struct DFAState* queueFront){  // 辅助函数
    //printf("initGroupSet: \n");
    // 根据终态/非终态，初始化分组集合
    // 同一组内用第一条边串接
    int groupNum = 0;
    bool isHaveAcceptGroup = false;  // 是否有终态分组
    bool isHaveNonAcceptGroup = false;  // 是否有非终态分组
    struct DFAState* acceptGroup,*nonAcceptGroup;
    while(queueFront!=NULL){  // 队列不为空
        struct DFAState* temp = queueFront->edgeOut->next;  // 保存下一个
        if(queueFront->isAccept){  // 终态
            if(isHaveAcceptGroup==false){  // 没有终态分组
                isHaveAcceptGroup = true;
                addDFAEdge(groupSet,queueFront,none);  // 添加边连接分组
                acceptGroup = queueFront;
                groupNum++;
            }
            else{  // 有终态分组
                // 将其连接到对应分组后面
                acceptGroup->edgeOut->next = queueFront;
                acceptGroup = queueFront;
            }
            acceptGroup->edgeOut->next = NULL;  // 队尾置空
            acceptGroup->nfaStateNum = groupNum-1;  // 作为分组标签
        }
        else{  // 非终态
            if(isHaveNonAcceptGroup==false){  // 没有非终态分组
                isHaveNonAcceptGroup = true;
                addDFAEdge(groupSet,queueFront,none);  // 添加边连接分组
                nonAcceptGroup = queueFront;
                groupNum++;
            }
            else{  // 有非终态分组
                // 将其连接到对应分组后面
                nonAcceptGroup->edgeOut->next = queueFront;
                nonAcceptGroup = queueFront;
            }
            nonAcceptGroup->edgeOut->next = NULL;  // 队尾置空
            nonAcceptGroup->nfaStateNum = groupNum-1;  // 作为分组标签
        }
        // 出队（把队列头指向下一个）
        queueFront = temp;
    }
    return groupNum;
}

void testGroup(struct DFAState* groupSet,int groupNum){  // 辅助函数，测试用
    // 打印各个分组集合
    printf("testGroup: \n");
    struct DFAEdge* groupPtr = groupSet->edgeOut->nextEdge;  // 第一条边没有用
    for(int i=0;i<groupNum;i++){
        struct DFAState* queueFront = groupPtr->next;  // 一组的队列头
        while(queueFront!=NULL){  // 队列不为空
            printf("%d ",queueFront->id);
            // 出队（把队列头指向下一个）
            queueFront = queueFront->edgeOut->next;
        }
        printf("\n");
        // 下一个分组
        groupPtr = groupPtr->nextEdge;
    }
}

int makeAMove(struct DFAState* s,char c){  // 辅助函数，返回下一个状态的分组标签
    struct DFAEdge* e = s->edgeOut->nextEdge;  // 第一条边没有用
    // 没有边出去算死状态
    for(int i=1;i<s->edgeNum;i++){
        if(e->c==c)
            return e->next->nfaStateNum;
        e = e->nextEdge;
    }
    return -1;
}

bool isInTheSameGroup(struct DFAState* this,struct DFAState* next){  // 辅助函数
    // 判断两个状态是否在同一组
    struct symbol *s = symbolTable;
    // 遍历每个字符
    for(int i=0;i<totalSymbolNum;i++){
        // 取出一个字符
        char c = s->c;
        s = s->next;
        // 比较两个状态到达的终点是否是同一分组
        int thisGroup = makeAMove(this,c);
        int nextGroup = makeAMove(next,c);
        //printf("thisGroup%d: %d, nextGroup%d: %d\n",this->id,thisGroup,next->id,nextGroup);
        if(thisGroup!=nextGroup)
            return false;
    }
    return true;
}

int divideGroup(struct DFAState* groupSet,struct DFAState* groupPtr,int nowGroupNum){  // 分组继续划分
    struct DFAState* thisGroup, *nextGroup = groupPtr;  // 从nextGroup划分出group
    struct DFAState* thisEnd, *nextEnd;
    bool isFirstDivide = true;  // 是否是第一次划分
    // 一次划分一组
    while(nextGroup!=NULL){
        thisGroup = nextGroup;
        nextGroup = NULL;  // 待分组集合

        struct DFAState* nextGroupEntry = thisGroup;  // 从thisGroup划分出nextGroupEntry到待分组集合
        while(nextGroupEntry!=NULL){
            struct DFAState* temp = nextGroupEntry->edgeOut->next;  // 保存下一个
            if(isInTheSameGroup(thisGroup,nextGroupEntry)){  // 在同一组
                // 将其连接到对应分组后面
                if(thisGroup!=nextGroupEntry)  // 不是第一个
                    thisEnd->edgeOut->next = nextGroupEntry;
                thisEnd = nextGroupEntry;
                thisEnd->edgeOut->next = NULL;  // 队尾置空
            }
            else{
                // 不在同一组，拿出nextGroupEntry到待分组集合
                if(nextGroup==NULL){  // 第一次
                    nextGroup = nextGroupEntry;
                    nextEnd = nextGroup;
                    nowGroupNum++;
                }
                else{  // 不是第一次
                    // 将其连接到对应分组后面
                    nextEnd->edgeOut->next = nextGroupEntry;
                    nextEnd = nextGroupEntry;
                }
                nextEnd->edgeOut->next = NULL;  // 队尾置空
                nextEnd->nfaStateNum = nowGroupNum-1;  // 新的分组标签
            }
            nextGroupEntry = temp;
        }

        if(isFirstDivide){  // 第一次划分
            // 之前已经有一个分组了，不需要新建
            isFirstDivide = false;
        }
        else{  // 不是第一次划分
            // 将thisGroup连接到groupSet中
            addDFAEdge(groupSet,thisGroup,none);
        }
    }
    return nowGroupNum;
}

struct DFAState* getTheGroup(struct DFAState* start,int groupNum,int groupLabel){  // 辅助函数
    // 根据分组标签，找到对应的分组
    for(int i=0;i<groupNum;i++){
        if(start->nfaStateNum==groupLabel)
            return start;
        start = start->edgeOut->next;
    }
    return NULL;
}

void printDFA(struct DFA* dfa,int groupNum){
    struct DFAState* test = dfa->start;
    for(int i=0;i<groupNum;i++){
        printf("State: %d",test->id);
        struct DFAEdge* testEdge = test->edgeOut->nextEdge;
        for(int j=1;j<test->edgeNum;j++){
            printf(" -%c-> %d ",testEdge->c,testEdge->next->id);
            testEdge = testEdge->nextEdge;
        }
        printf("\n");
        test = test->edgeOut->next;
    }
}

struct DFA* minimizeDFA(struct DFA* dfa){
    struct DFA* minDFA = (struct DFA*)malloc(sizeof(struct DFA));

    struct DFAState* groupSet = newDFAState(0);  // 分组集合，不使用第一条边
    // 初始化分组集合，分为终态和非终态
    int groupNum = initGroupSet(groupSet,dfa->start), temp = 0;  // 分组数量
    //testGroup(groupSet,groupNum);

    // 循环构建分组
    while(groupNum!=temp){  // 如果前后两次分组没变，说明已经收敛
        temp = groupNum;
        struct DFAEdge* groupPtr = groupSet->edgeOut->nextEdge;  // 第一条边没有用
        for(int i=0;i<temp;i++){  // 试探当前每一个分组是否还能够再细分
            struct DFAState* queueFront = groupPtr->next;  // 一组的队列头
            groupNum = divideGroup(groupSet,queueFront,groupNum);  // 组内划分
            groupPtr = groupPtr->nextEdge;
        }
    }
    //testGroup(groupSet,groupNum);

    // 新建DFA状态，由minDFA连接
    struct DFAEdge* groupPtr = groupSet->edgeOut->nextEdge;  // 第一条边没有用
    struct DFAState* queueFront,*queueRear;
    for(int i=0;i<groupNum;i++){
        queueFront = groupPtr->next;  // 一组的队列头
        struct DFAState* newState = newDFAState(0);  // 新建DFA状态
        newState->id = i;  // id
        newState->isAccept = queueFront->isAccept;  // 是否是接收状态
        newState->nfaStateNum = queueFront->nfaStateNum;  // 分组标签
        // 添加到minDFA
        if(i==0){
            minDFA->start = newState;
        }
        else{
            queueRear->edgeOut->next = newState;
        }
        queueRear = newState;
        queueRear->edgeOut->next = NULL;  // 队尾置空
        // 下一组
        groupPtr = groupPtr->nextEdge;
    }
    //printDFA(minDFA,groupNum);


    // 构建新状态之间的边
    groupPtr = groupSet->edgeOut->nextEdge;  // 第一条边没有用
    for(int i=0;i<groupNum;i++){
        queueFront = groupPtr->next;  // 一组的队列头
        struct symbol *s = symbolTable;
        // 遍历每个字符
        for(int j=0;j<totalSymbolNum;j++){
            // 取出一个字符
            char c = s->c;
            s = s->next;
            // 求出下一个状态的分组标签
            int nextGroupLabel = makeAMove(queueFront,c);
            if(nextGroupLabel==-1)  // 没有边出去
                continue;

            // 根据分组标签找到对应的分组
            struct DFAState* thisGroup = getTheGroup(minDFA->start,groupNum,queueFront->nfaStateNum);
            struct DFAState* nextGroup = getTheGroup(minDFA->start,groupNum,nextGroupLabel);
            // 添加边
            addDFAEdge(thisGroup,nextGroup,c);
        }
        // 出队（把队列头指向下一个）
        groupPtr = groupPtr->nextEdge;
    }

    // 释放原DFA内存
    struct DFAState* freelist;
    struct DFAEdge* freeEdge;
    groupPtr = groupSet->edgeOut->nextEdge;  // 挨个释放每一组
    for(int i=0;i<groupNum;i++){
        queueFront = groupPtr->next;  // 一组的队列头
        while(queueFront!=NULL){  // 释放一组的每个状态
            freelist = queueFront;
            queueFront = queueFront->edgeOut->next;
            for(int j=0;j<freelist->edgeNum;j++){  // 释放每条边
                freeEdge = freelist->edgeOut;
                freelist->edgeOut = freelist->edgeOut->nextEdge;
                free(freeEdge);
            }
            free(freelist);
        }
        // 下一组
        groupPtr = groupPtr->nextEdge;
    }
    // 释放分组集合
    for(int i=0;i<groupSet->edgeNum;i++){
        freeEdge = groupSet->edgeOut;
        groupSet->edgeOut = groupSet->edgeOut->nextEdge;
        free(freeEdge);
    }
    free(groupSet);

    // test
    printDFA(minDFA,groupNum);

    return minDFA;
}

void dumpMinDFA(struct DFA* dfa){  // 输出到dot文件
    char filename[20];
    sprintf(filename,"minDFA%d.dot",FILE_NUM);
    FILE *fp = fopen(filename, "w");
    if (fp == NULL){
        printf("error opening file\n");
        exit(-1);
    }
    fprintf(fp,"digraph G {\n");

    struct DFAState* queueFront;
    struct DFAEdge* edgePtr;
    // 初始化队列
    queueFront = dfa->start;

    while(queueFront!=NULL){  // 队列不为空
        edgePtr = queueFront->edgeOut->nextEdge;  // 第一条边负责串接队列
        for(int i=1;i<queueFront->edgeNum;i++){  // BFS遍历出边
            // 打印状态图
            fprintf(fp,"\t%d -> %d [label=\"%c\"];\n",queueFront->id,edgePtr->next->id,edgePtr->c);
            edgePtr = edgePtr->nextEdge;
        }
        // 打印接收状态
        if(queueFront->isAccept)
            fprintf(fp,"\t%d [shape=doublecircle];\n",queueFront->id);
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut->next;
    }

    fprintf(fp,"}\n");
    fclose(fp);

    // 释放DFA内存
    struct DFAState* freelist;
    struct DFAEdge* freeEdge;
    queueFront = dfa->start;
    while(queueFront!=NULL){  // 释放每个状态
        freelist = queueFront;
        queueFront = queueFront->edgeOut->next;
        for(int j=0;j<freelist->edgeNum;j++){  // 释放每条边
            freeEdge = freelist->edgeOut;
            freelist->edgeOut = freelist->edgeOut->nextEdge;
            free(freeEdge);
        }
        free(freelist);
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