%option noyywrap
%option yylineno
%{
    /*
    * You will need to comment this line in lab5.
    */
    #define ONLY_FOR_LEX
    #ifdef ONLY_FOR_LEX
    #else
    #define YYSTYPE void *
    #include "parser.h"
    #endif

    #define YY_NO_UNPUT
    #define YY_NO_INPUT
    #include <string>
    #define ID 70 
    #define NUM

    #ifdef ONLY_FOR_LEX
    #include <ostream>
    #include <fstream>
    using namespace std;
    extern FILE *yyin; 
    extern FILE *yyout;
    int IDcount=0;//IDcount
    char map[100][100];//符号表
    int l_scope=0;//左括号数量
    int r_scope=0;//右括号数量
    int new_scope=0;//作用域标记符
    int old_scope=0;
    int scope[100];
    int t_scope=-1;

    void DEBUG_FOR_LAB4(std::string s){
        std::string DEBUG_INFO = s +"\t\t" + std::to_string(yylineno) +"\t\t"+ "\n";
        fputs(DEBUG_INFO.c_str(), yyout);
    }
    #endif
%}

DECIMIAL ([1-9][0-9]*|0)
OCTAL (0[0-7]+)
EOL (\r\n|\n|\r)
WHITE [\t ]
%x BLOCKCOMMENT
digit [0-9]
letter [A-Za-z]
id ({letter}|_)({letter}|{digit}|_)*
number [1-9]{digit}*|0
commentbegin "/*"
commentelement .|\n
commentend "*/"
%x COMMENT
%%


{number} {fprintf(yyout,"NUM\t\t%s\t\t%d\n",yytext,yylineno);}
"int" {
    /*
    * Questions: 
    *   Q1: Why we need to return INT in further labs?
    *   Q2: What is "INT" actually?
    */
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("INT\t\tint");
    #else
        return INT;
    #endif
}
"void" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("VOID\t\tvoid");
    #else
        return VOID;
    #endif 
}
"if" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("IF\t\tif");
    #else
        return IF;
    #endif
};
"else" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("ELSE\t\telse");
    #else
        return ELSE;
    #endif
};
"return" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("RETURN\t\treturn");
    #else
        return RETURN;
    #endif
}
"while" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("WHILE\t\twhile");
    #else
        return WHILE;
    #endif
}

"=" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("ASSIGN\t\t=");
    #else
        return ASSIGN;
    #endif
}
"<" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("LESS\t\t<");
    #else
        return LESS;
    #endif
}
"+" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("ADD\t\t+");
    #else
        return ADD;
    #endif
}
";" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("SEMICOLON\t;");
    #else
        return SEMICOLON;
    #endif
}
"(" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("LPAREN\t\t(");
    #else
        return LPAREN;
    #endif
}
")" {
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("RPAREN\t\t)");
    #else
    return RPAREN;
    #endif
}



"{" {
    t_scope++;
    scope[t_scope]=IDcount;
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("LBRACE\t\t{");
    #else
        return LBRACE;
    #endif
    }
"}" {
    IDcount=scope[t_scope];
    t_scope--;
    #ifdef ONLY_FOR_LEX
        DEBUG_FOR_LAB4("RBRACE\t\t}");
    #else
        return RBRACE;
    #endif
    }
 {id} {
        int flag = 0;
        int i = 0;
        int t;
        if(t_scope==-1)
        {
            t=0;
        }
        else{
            t=scope[t_scope];
        }
        for(i=IDcount-1;i>=t;i--)
        {
           if(strcmp(yytext,map[i])==0)
           {
               flag=1;break;
           }
        }
        if(flag==1&&new_scope==old_scope)//匹配到已有字符但仍处在旧的作用域
        {
           fprintf(yyout,"ID\t\t%s\t\t%d\t\t%p\n",yytext,yylineno,map[i]);
        }
        else//没有匹配到已有字符或者来到了新的作用域
        {
             IDcount++;
             strcpy(map[IDcount-1],yytext);
             fprintf(yyout,"ID\t\t%s\t\t%d\t\t%p\n",yytext,yylineno,map[IDcount-1]);
        }
}
{EOL} //yylineno++;
{WHITE}




%%

#ifdef ONLY_FOR_LEX
int main(int argc, char **argv){
    memset(map, 0, sizeof(map));
    if(argc != 5){
        fprintf(stderr, "Argument Not Enough");
        exit(EXIT_FAILURE);
    }

    if(!(yyin = fopen(argv[1], "r"))){
        fprintf(stderr, "No such file or directory: %s", argv[1]);
        exit(EXIT_FAILURE);
    }

    if(!(yyout = fopen(argv[3], "w"))){
        fprintf(stderr, "No such file or directory: %s", argv[3]);
        exit(EXIT_FAILURE);
    }
    fprintf(yyout,"token \t\tname \t\tlineno\t\tposition_in_scope\n");
    yylex();
    yylineno=1;
    
    return 0;
}
#endif
