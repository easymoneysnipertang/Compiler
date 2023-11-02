/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 1 "AllInOne.y"

/*********************************************
YACC file
可以用C++写！！！
1. 实现Thompson构造法，从正则表达式转NFA(finish date:2023/10/20)
2. 实现子集构造法，从NFA转DFA(finish date:2023/10/22)
3. 实现DFA的最小化(finish date:2023/10/27)
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

// 模拟DFA
void runDFA(struct DFA* dfa);



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




#line 185 "AllInOne.tab.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif


/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token kinds.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    YYEMPTY = -2,
    YYEOF = 0,                     /* "end of file"  */
    YYerror = 256,                 /* error  */
    YYUNDEF = 257,                 /* "invalid token"  */
    OR = 258,                      /* OR  */
    CLOSURE = 259,                 /* CLOSURE  */
    LBRACE = 260,                  /* LBRACE  */
    RBRACE = 261,                  /* RBRACE  */
    QUIT = 262,                    /* QUIT  */
    CHAR = 263,                    /* CHAR  */
    CONNECT = 264                  /* CONNECT  */
  };
  typedef enum yytokentype yytoken_kind_t;
#endif
/* Token kinds.  */
#define YYEMPTY -2
#define YYEOF 0
#define YYerror 256
#define YYUNDEF 257
#define OR 258
#define CLOSURE 259
#define LBRACE 260
#define RBRACE 261
#define QUIT 262
#define CHAR 263
#define CONNECT 264

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 115 "AllInOne.y"

    char cval;  // 字符
    struct NFA* nval;  // 控制NFA

#line 258 "AllInOne.tab.c"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;


int yyparse (void);



/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* "end of file"  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_OR = 3,                         /* OR  */
  YYSYMBOL_CLOSURE = 4,                    /* CLOSURE  */
  YYSYMBOL_LBRACE = 5,                     /* LBRACE  */
  YYSYMBOL_RBRACE = 6,                     /* RBRACE  */
  YYSYMBOL_QUIT = 7,                       /* QUIT  */
  YYSYMBOL_CHAR = 8,                       /* CHAR  */
  YYSYMBOL_CONNECT = 9,                    /* CONNECT  */
  YYSYMBOL_10_ = 10,                       /* ';'  */
  YYSYMBOL_YYACCEPT = 11,                  /* $accept  */
  YYSYMBOL_lines = 12,                     /* lines  */
  YYSYMBOL_expr = 13,                      /* expr  */
  YYSYMBOL_term_connect = 14,              /* term_connect  */
  YYSYMBOL_term = 15                       /* term  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;




#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int8 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  2
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   19

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  11
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  5
/* YYNRULES -- Number of rules.  */
#define YYNRULES  12
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  17

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   264


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX)                                \
  (0 <= (YYX) && (YYX) <= YYMAXUTOK                     \
   ? YY_CAST (yysymbol_kind_t, yytranslate[YYX])        \
   : YYSYMBOL_YYUNDEF)

/* YYTRANSLATE[TOKEN-NUM] -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex.  */
static const yytype_int8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,    10,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9
};

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_uint8 yyrline[] =
{
       0,   141,   141,   160,   161,   162,   164,   165,   167,   168,
     170,   171,   172
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "\"end of file\"", "error", "\"invalid token\"", "OR", "CLOSURE",
  "LBRACE", "RBRACE", "QUIT", "CHAR", "CONNECT", "';'", "$accept", "lines",
  "expr", "term_connect", "term", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-5)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-1)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int8 yypact[] =
{
      -5,     0,    -5,    -4,    -5,    -5,    -5,    -1,    -5,     7,
      10,    -4,    -5,    -5,    -5,    -5,    -5
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int8 yydefact[] =
{
       5,     0,     1,     0,     4,    12,     3,     0,     7,     9,
       0,     0,     2,    10,     8,    11,     6
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
      -5,    -5,     3,     8,    -5
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
       0,     1,     7,     8,     9
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int8 yytable[] =
{
       2,     3,    11,     0,     5,     3,    10,     4,     5,    12,
       6,    13,     3,    11,     0,     5,    15,    14,     0,    16
};

static const yytype_int8 yycheck[] =
{
       0,     5,     3,    -1,     8,     5,     3,     7,     8,    10,
      10,     4,     5,     3,    -1,     8,     6,     9,    -1,    11
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int8 yystos[] =
{
       0,    12,     0,     5,     7,     8,    10,    13,    14,    15,
      13,     3,    10,     4,    14,     6,    14
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr1[] =
{
       0,    11,    12,    12,    12,    12,    13,    13,    14,    14,
      15,    15,    15
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     3,     2,     2,     0,     3,     1,     2,     1,
       2,     3,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;


/*-----------.
| yybackup.  |
`-----------*/
yybackup:
  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= YYEOF)
    {
      yychar = YYEOF;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yytable_value_is_error (yyn))
        goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2: /* lines: lines expr ';'  */
#line 141 "AllInOne.y"
                               {    nfa_state_num=0; 
                                    dumpNFA((yyvsp[-1].nval));   // 输出到dot文件
                                    printf("----dump NFA----\n");
                                    
                                    struct DFA* dfa = NFA2DFA((yyvsp[-1].nval));  // 子集构造法
                                    dumpDFA(dfa);  // 输出到dot文件
                                    printf("----dump DFA----\n");

                                    struct DFA* min_dfa = minimizeDFA(dfa);  // 最小化DFA
                                    dumpMinDFA(min_dfa);  // 输出到dot文件
                                    printf("----minimize DFA----\n");

                                    printf("----run the DFA----\n");
                                    runDFA(min_dfa);  // 模拟DFA

                                    cleanSymbolTable();  // 清空符号表
                                    FILE_NUM++;
                                    printf("------------------\n"); 
                                }
#line 1266 "AllInOne.tab.c"
    break;

  case 4: /* lines: lines QUIT  */
#line 161 "AllInOne.y"
                            { exit(0); }
#line 1272 "AllInOne.tab.c"
    break;

  case 6: /* expr: expr OR term_connect  */
#line 164 "AllInOne.y"
                                     { (yyval.nval) = orNFA((yyvsp[-2].nval),(yyvsp[0].nval)); }
#line 1278 "AllInOne.tab.c"
    break;

  case 7: /* expr: term_connect  */
#line 165 "AllInOne.y"
                             { (yyval.nval) = (yyvsp[0].nval); }
#line 1284 "AllInOne.tab.c"
    break;

  case 8: /* term_connect: term term_connect  */
#line 167 "AllInOne.y"
                                          { (yyval.nval) = connectNFA((yyvsp[-1].nval),(yyvsp[0].nval)); }
#line 1290 "AllInOne.tab.c"
    break;

  case 9: /* term_connect: term  */
#line 168 "AllInOne.y"
                     { (yyval.nval) = (yyvsp[0].nval); }
#line 1296 "AllInOne.tab.c"
    break;

  case 10: /* term: term CLOSURE  */
#line 170 "AllInOne.y"
                             { (yyval.nval) = closureNFA((yyvsp[-1].nval)); }
#line 1302 "AllInOne.tab.c"
    break;

  case 11: /* term: LBRACE expr RBRACE  */
#line 171 "AllInOne.y"
                                   { (yyval.nval) = (yyvsp[-1].nval); }
#line 1308 "AllInOne.tab.c"
    break;

  case 12: /* term: CHAR  */
#line 172 "AllInOne.y"
                     {  (yyval.nval) = newNFA((yyvsp[0].cval)); 
                        addSymbol((yyvsp[0].cval));  // 添加到符号表   
                    }
#line 1316 "AllInOne.tab.c"
    break;


#line 1320 "AllInOne.tab.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= YYEOF)
        {
          /* Return failure if at end of input.  */
          if (yychar == YYEOF)
            YYABORT;
        }
      else
        {
          yydestruct ("Error: discarding",
                      yytoken, &yylval);
          yychar = YYEMPTY;
        }
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
            {
              yyn = yytable[yyn];
              if (0 < yyn)
                break;
            }
        }

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
        YYABORT;


      yydestruct ("Error: popping",
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 178 "AllInOne.y"


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
                    for(int i=0;i<DestState->nfaStateNum;i++){
                        struct State* temp = DestState->nfaState->edgeOut[2].next;
                        free(DestState->nfaState);
                        DestState->nfaState = temp;
                    }
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
        if(e->c==c){
            //printf("makeAMove: %d -%c-> %d\n",s->nfaStateNum,c,e->next->nfaStateNum);
            return e->next->nfaStateNum;
        }
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
                thisEnd->nfaStateNum = thisGroup->nfaStateNum;  // 分组标签
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
    //printDFA(minDFA,groupNum);

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
}


// 模拟DFA
void runDFA(struct DFA* dfa){
    while(true){
        // 输入字符串
        char str[30];
        printf("input: ");
        scanf("%s",str);
        if(strcmp(str,"#")==0)  // 退出
            break;
        int len = strlen(str);

        // 模拟DFA运行
        struct DFAState* queueFront = dfa->start;  // 开始状态
        bool getNext = false;  // 是否模拟成功
        for(int i=0;i<len;i++){
            getNext = false;
            // 取出一个字符
            char c = str[i];
            if(c==none)  // 空串
                continue;
            // 遍历每个出边
            struct DFAEdge* edgePtr = queueFront->edgeOut->nextEdge;  // 第一条边没有用
            for(int j=1;j<queueFront->edgeNum;j++){
                if(edgePtr->c==c){  // 找到个符合的边
                    queueFront = edgePtr->next;  // 下一个状态
                    getNext = true;
                    break;
                }
                edgePtr = edgePtr->nextEdge;
            }
            if(!getNext)  // 都没有找到出边，不用再做下一次了
                break;
        }
        if(getNext&&queueFront->isAccept)
            printf("accept\n");
        else
            printf("reject\n");
    }

    // 释放DFA内存
    struct DFAState* freelist;
    struct DFAEdge* freeEdge;
    struct DFAState* queueFront = dfa->start;
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
