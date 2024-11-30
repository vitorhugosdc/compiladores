%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "y.tab.h"
    int count_line;
    

%}

%option yylineno
%option noyywrap
alfabeto_min [a-z]
alfabeto_mai [A-Z]
digito [0-9]

%%

"integer"                       { strcpy(yylval.node_struct.name,(yytext));printf("[%s]: TK_INT\n",yytext); return TK_INT; }
"float"                     {strcpy(yylval.node_struct.name,(yytext));  printf("[%s]: TK_FLOAT\n",yytext); return TK_FLOAT; }
"char"                      { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_CHAR\n",yytext) ; return TK_CHAR; }
"empty"                     { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_VOID\n",yytext); return TK_VOID; }
"string"                    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_STRING\n",yytext); return TK_STRING; }
"Main"                 { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_MAIN\n",yytext); return TK_MAIN;}
"Class"                    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_CLASS\n",yytext); return TK_CLASS; }
"main"                      { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_MAIN_METHOD\n",yytext); return TK_MAIN_METHOD; }
"print"                   { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_PRINTF\n",yytext); return TK_PRINTF; }
"scan"                      { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_SCANF\n",yytext); return TK_SCANF; }
"return"                   { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_RETURN\n",yytext); return TK_RETURN; }
"for"	                    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_FOR\n",yytext); return TK_FOR; }
"if"	                    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_IF\n",yytext); return TK_IF; }
"else"	                    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_ELSE\n",yytext); return TK_ELSE; }
"vect"	                    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_VECTOR\n",yytext); return TK_VECTOR; }
^"#include"[ ]*<.+\.vh>    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_INCLUDE\n",yytext); return TK_INCLUDE; }
"true"                { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_TRUE\n",yytext); return TK_TRUE; }
"false"                     { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_FALSE\n",yytext); return TK_FALSE; }
[-]?{digito}+                { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_NUMBER\n",yytext); return TK_NUMBER; }
[-]?{digito}+\.{digito}{1,6} { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_FLOAT_NUMBER\n",yytext); return TK_FLOAT_NUMBER; }
["].*["]                    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_STR\n",yytext); return TK_STR; }
['].[']                     { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_CH\n",yytext); return TK_CH; }
{alfabeto_mai}{alfabeto_min}*   { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_CLASS_NAME\n",yytext); return TK_CLASS_NAME; }
{alfabeto_min}({alfabeto_min}|{digito}|[_])*   { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_ID\n",yytext); return TK_ID; }
"<="                        { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_LESS_EQUAL\n",yytext); return TK_LESS_EQUAL; }
">="                        { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_GREATER_EQUAL\n",yytext); return TK_GREATER_EQUAL; }
"=="                        { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_EQUAL\n",yytext); return TK_EQUAL; }
"!="                        { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_NOT_EQUAL\n",yytext); return TK_NOT_EQUAL; }
">"	                        { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_GREATER\n",yytext); return TK_GREATER; }
"<"	                        { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_LESS\n",yytext); return TK_LESS; }
"&&"	                    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_AND\n",yytext); return TK_AND; }
"||"	                    { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_OR\n",yytext); return TK_OR; }
"+"                         { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_PLUS\n",yytext); return TK_PLUS; }
"-"                         { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_MINUS\n",yytext); return TK_MINUS; }
"/"                         { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_DIVISION\n",yytext); return TK_DIVISION; }
"*"                         { strcpy(yylval.node_struct.name,(yytext)); printf("[%s]: TK_MULTIPLY\n",yytext); return TK_MULTIPLY; }
\/\/.*                      { ; }
\/\*(.*\n)*.*\*\/           { ; } 
[ \t]*                      { ; }
[\n]                        { count_line++; }
.	                        { return *yytext; } 


%%
/*
int yywrap() {
    return 1;
}
*/