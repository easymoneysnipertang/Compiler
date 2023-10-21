%{
/*********************************************
YACC file
1. 实现Thompson构造法，从正则表达式转NFA(finish date:2023/10/20)
2. 实现子集构造法，从NFA转DFA(finish date:)
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
void testSet(struct State* t);
int epsilonClosure(struct State* T_begin,struct State* T_end);
struct DFA* NFA2DFA(struct NFA* nfa);


#define none '$'  // 空串
int FILE_NUM = 0;  // 一行一个文件

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

struct DFAEdge{  // DFA的一条边
    char c;  // 边上的字符
    struct DFAState* next;  // 边指向的下一个状态
};
struct DFAState{  // DFA的一个状态
    int id;  // 状态编号
    struct State* nfaState;  // 对应的NFA状态
    int nfaStateNum;  // 对应的NFA状态的数量
    struct DFAEdge* edgeOut;  // 状态的出边
    int edgeNum;  // 出边的数量
};
struct DFA{
    struct DFAState* start;  // 开始状态
    struct DFAState* end;  // 结束状态
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
                                    dumpNFA($2); 
                                    printf("----------\n"); 
                                    FILE_NUM++;
                                    NFA2DFA($2);
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
        |       CHAR { $$ = newNFA($1); }  // 新建一个NFA
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
                queueRear->id = id++;  // 状态编号
                queueRear->edgeOut[2].next = NULL;  // 队列尾的下一个置空
                queueRear->visited = true;  // 进队列就代表访问过了，不重复进
            }
            // 打印状态图
            fprintf(fp,"\t%d -> %d [label=\"%c\"];\n",queueFront->id,queueFront->edgeOut[i].next->id,queueFront->edgeOut[i].c);
        }
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut[2].next;
    }
    fprintf(fp,"}\n");
    fclose(fp);
    // 不释放队列，后续转DFA接着用
    nfa_state_num = id;  // 记录nfa总状态数
}

// 子集构造法，从NFA转DFA
void testSet(struct State* t){
    printf("testSet\n");
    struct State* s = t;
    while(s!=NULL){
        printf("State%d ",s->id);
        s = s->edgeOut[2].next;
    }
    printf("\n");
}

int epsilonClosure(struct State* T_begin,struct State* T_end){  // 求闭包
    // 从T出发，经过空串能到达的状态集合
    bool* visited = (bool*)malloc(sizeof(bool)*nfa_state_num);  // 记录是否访问过
    int num=1;  // 记录集合中状态的数量
    // 状态链接在state的第三条边上，链表构成集合
    struct State* queueFront,*queueRear;
    // 传入的T是一个集合
    queueFront = queueRear = T_begin;
    while(queueRear!=T_end){  // 找到T的尾部
        visited[queueRear->id] = true;  // 进队列就代表访问过了，不重复进
        queueRear = queueRear->edgeOut[2].next;
    }
    visited[queueRear->id] = true;  // 尾部不漏
    while(queueFront!=NULL){  // 队列不为空
        for(int i=0;i<queueFront->edgeNum;i++){  // BFS遍历出边
            if(queueFront->edgeOut[i].c==none&&visited[queueFront->edgeOut[i].next->id]==false){  // 没有访问过，入队
                // 连接到队列尾
                queueRear->edgeOut[2].next = queueFront->edgeOut[i].next;
                queueRear = queueRear->edgeOut[2].next;
                queueRear->edgeOut[2].next = NULL;  // 队列尾的下一个置空
                visited[queueRear->id] = true;  // 进队列就代表访问过了，不重复进
                num++;
            }
        }
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut[2].next;
    }
    free(visited);
    // 返回的链表是有序的，因为我id就是这么给的
    return num;
}

struct State* move(struct State* T_begin,char c,int T_num,struct State* Dest){  // move
    // 从T出发，经过c能到达的状态集合
    bool* visited = (bool*)malloc(sizeof(bool)*nfa_state_num);  // 记录是否访问过
    // 状态链接在state的第三条边上，链表构成集合
    struct State* queueFront = T_begin,*DestBegin = NULL;
    // 遍历集合，每个状态执行一个动作
    for(int i=0;i<T_num;i++)
    {
        // 遍历每个状态的出边
        for(int j=0;j<queueFront->edgeNum;j++){
            if(queueFront->edgeOut[j].c==c&&visited[queueFront->edgeOut[j].next->id]==false){  // 找到个符合的边
                if(DestBegin==NULL){  // 第一个
                    DestBegin = Dest = queueFront->edgeOut[j].next;
                }
                else{  // 不是第一个
                    // 连接到队列尾
                    Dest->edgeOut[2].next = queueFront->edgeOut[j].next;
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
    // TODO：有可能一个都没有
    return DestBegin;
}

struct DFA* NFA2DFA(struct NFA* nfa){
    int id = 0;
    struct DFA* dfa = (struct DFA*)malloc(sizeof(struct DFA));
    // 开始状态
    struct DFAState* start = (struct DFAState*)malloc(sizeof(struct DFAState));
    start->edgeNum = 0;
    start->nfaStateNum = epsilonClosure(nfa->start,nfa->start);
    start->nfaState = nfa->start;
    start->id = id++;  // id直接编号
    testSet(start->nfaState);
    // 初始化队列
    struct DFAState* queueFront,*queueRear;
    queueFront = queueRear = start;
    // 遍历每个未标记状态
    while(queueFront!=NULL){
        // 遍历每个字符
        for(char c='a';c<='z';c++){  // TODO：创建字符表
            // move
            struct State* DestBegin,*Dest=NULL;
            DestBegin = move(queueFront->nfaState, c, queueFront->nfaStateNum, Dest);
            if(DestBegin==NULL)  // 没有move出去
                continue;
            else{
                // 计算epsilon闭包
                int DestNum = epsilonClosure(DestBegin,Dest);
                // 创建新状态
                struct DFAState* DestState = (struct DFAState*)malloc(sizeof(struct DFAState));
                DestState->edgeNum = 0;
                DestState->nfaStateNum = DestNum;
                DestState->nfaState = DestBegin;
                // TODO：判断是否存在，进而决定是否加入队列和id，还有给front添加edge！
                
                // 下面是copilot生成↓，后面慢慢改
                // 判断是否已经存在
                struct DFAState* temp = dfa->start;
                bool flag = false;
                while(temp!=NULL){
                    if(temp->nfaStateNum==Dest->nfaStateNum){
                        flag = true;
                        break;
                    }
                    temp = temp->edgeOut[2].next;
                }
                if(flag==false){  // 不存在
                    // 连接到队列尾
                    queueRear->edgeOut[queueRear->edgeNum].c = c;
                    queueRear->edgeOut[queueRear->edgeNum++].next = Dest;
                    queueRear = queueRear->edgeOut[queueRear->edgeNum-1].next;
                    queueRear->edgeOut[2].next = NULL;  // 队列尾的下一个置空
                }
                else{  // 存在
                    // 连接到队列尾
                    queueRear->edgeOut[queueRear->edgeNum].c = c;
                    queueRear->edgeOut[queueRear->edgeNum++].next = temp;
                    queueRear = queueRear->edgeOut[queueRear->edgeNum-1].next;
                    queueRear->edgeOut[2].next = NULL;  // 队列尾的下一个置空
                }
            }
        }
        // 出队（把队列头指向下一个）
        queueFront = queueFront->edgeOut[2].next;
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