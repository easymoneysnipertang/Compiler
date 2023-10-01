# CFG for a subset of SysY

## 需要实现的SysY特性
1. 数据类型：int
2. 变量声明、常量声明，常量、变量的初始化
3. 语句：赋值（=）、表达式语句、语句块、if、while、return
4. 表达式：算术运算（+、-、*、/、%，其中+、-都可以是单目运算符）、关系运算（==，>，<，>=，<=，!=）和逻辑运算（&&（与）、||（或）、!（非））
5. 注释
6. 输入输出（实现连接SysY运行时库，参见文档《SysY运行时库》）
7. 函数、语句块
    - 函数：函数声明、函数调用
    - 变量、常量作用域：在函数中、语句块（嵌套）中包含变量、常量声明的处理，break、continue语句
8. 数组：数组（一维、二维、…）的声明和数组元素访问
9. 浮点数：浮点数常量识别、变量声明、存储、运算

## CFG设计
### 1. 终结符
标识符 **Ident**
```
Ident    -> Nondigit
            | Ident Nondigit
            | Ident Digit
Nondigit -> '_' | 'a' | 'b' | ... | 'z' | 'A' | 'B' | ... | 'Z'
Digit    -> '0' | '1' | ... | '9'
```

整型常量 **IntConst**
```
IntConst           -> decimal-const | octal-const | hexadecimal-const
decimal-const      -> nonzero-digit | decimal-const digit
octal-const        -> '0' | octal-const octal-digit
hexadecimal-const  -> hexadecimal-prefix hexadecimal-digit
                      | hexadecimal-const hexadecimal-digit
hexadecimal-prefix -> '0x' | '0X'
nonzero-digit      -> '1' | '2' | ... | '9'
octal-digit        -> '0' | '1' | ... | '7'
digit              -> '0' | nonzero-digit
hexadecimal-digit  -> '0' | '1' | ... | '9'
                      | 'a' | 'b' | 'c' | 'd' | 'e' | 'f'
                      | 'A' | 'B' | 'C' | 'D' | 'E' | 'F'
```

浮点型常量 **FloatConst**
```
FloatConst -> decimal-float-const | hexadecimal-float-const
decimal-float-const ->  fractional-constant
                        | digit-sequence
                        | fractional-constant exponent-part
                        | digit-sequence exponent-part
hexadecimal-float-const -> hexadecimal-prefix hexadecimal-fractional-constant binary-exponent-part
                            | hexadecimal-prefix hexadecimal-digit-sequence binary-exponent-part

fractional-constant -> digit-sequence '.' digit-sequence
                        | digit-sequence '.'
exponent-part   -> 'e' sign digit-sequence
                       | 'E' sign digit-sequence 
sign -> '+' | '-'
digit-sequence -> digit | digit digit-sequence

hexadecimal-fractional-constant -> hexadecimal-digit-sequence '.' hexadecimal-digit-sequence
                                    | hexadecimal-digit-sequence '.'
binary-exponent-part -> 'p' sign digit-sequence
hexadecimal-digit-sequence -> hexadecimal-digit 
                                | hexadecimal-digit hexadecimal-digit-sequence
```

注释 **Comment**  -- unfinished
```
Comment -> '//' any-char-sequence
           | '/*' any-char-sequence '*/'
any-char-sequence -> any-char | any-char any-char-sequence
```

关键字 **Keyword**
```
void | int | float | if | else | while | break | continue | return |
const | Ident | IntConst | FloatConst
```

运算符 **Operator**
```
=、+、-、*、/、%、==、>、<、>=、<=、!=、&&、||、!
```

基本符号 **Symbol**
```
;、,、(、)、{、}、[、]、//、/*、*/、\n、\t
```

### 2. 开始符号
CompUnit

### 3. 产生式

```
CompUnit     -> CompUnit Decl | CompUnit FuncDef | ϵ
Decl         -> ConstDecl | VarDecl

ConstDecl    -> 'const' BType ConstDefList ';'
ConstDefList -> ConstDefList, ConstDef|ConstDef
BType        -> 'int' | 'float'
ConstDef     -> Ident Dim '=' ConstInitVal
Dim          -> Dim '[' ConstIntExp ']'|ϵ
ConstInitVal -> ConstExp | ConstValElement
ConstValElement -> ConstValEnum|ϵ
ConstValEnum -> ConstValEnum, ConstInitVal|ConstInitVal

VarDecl      -> BType VarDefList ';'
VarDefList   -> VarDefList, VarDef|VarDef
VarDef       -> Ident Dim|Ident Dim '=' InitVal
InitVal      -> Exp | '{'ValElements'}' 
ValElements  -> InitVal ',' ValElements | Initval | ϵ

FuncDef      -> FuncType Ident '(' FuncFParamList ')' Block
FuncType     -> 'void' | 'int'
FuncFParamList  -> FuncFParamList ',' FuncFParam | ϵ
FuncFParam   -> BType Ident ArraryOp
ArraryOp     -> Dim '[' ']' | ϵ

Block        -> '{' BlockItemList '}'
BlockItemList   -> BlockItemList BlockItem | ϵ
BlockItem    -> Decl | Stmt
Stmt         -> LVal '=' Exp ';'
                | ExpOp ';'
                | Block
                | 'if' '(' Cond ')' Stmt ElseOp
                | 'while' '(' Cond ')' Stmt
                | 'break' ';'
                | 'continue' ';'
                | 'return' ExpOp ';'
ExpOp        -> Exp | ϵ
ElseOp       -> 'else' Stmt | ϵ

Exp          -> AddExp
Cond         -> LOrExp
LVal         -> Ident Arrays
PrimaryExp   -> '(' Exp ')' | LVal | Number
Number       -> IntConst | FloatConst

UnaryExp     -> PrimaryExp
                | Ident '(' FuncRParamList ')'
                | UnaryOp UnaryExp
UnaryOp      -> '+' | '-' | '!'  // 注：保证 '!' 仅出现在 Cond 中
FuncRParamList  -> FuncRParamList ',' Exp | ϵ

MulExp       -> UnaryExp
                | MulExp '*' UnaryExp
                | MulExp '/' UnaryExp
                | MulExp '%' UnaryExp
AddExp       -> MulExp
                | AddExp ('+' | '−') MulExp
RelExp       -> AddExp
                | RelExp '<'  AddExp
                | RelExp '>'  AddExp
                | RelExp '<=' AddExp
                | RelExp '>=' AddExp
EqExp        -> RelExp
                | EqExp '==' RelExp
                | EqExp '!=' RelExp
LAndExp      -> EqExp
                | LAndExp '&&' EqExp
LOrExp       -> LAndExp
                | LOrExp '||' LAndExp
ConstExp     -> AddExp  // 在语义上额外约束这里的 AddExp 必须是一个可以在编译期求出值的常量
常量整型表达式：ConstIntExp  -> ConstExp//在语义上做限制，必须为整型
```

