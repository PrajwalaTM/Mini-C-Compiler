alphabet [A-Za-z]
digit [0-9]

%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yylineno=1;
int scopestack[100],c=0,top=-1;
char idname[10000];
void yyerror(char*);
extern FILE *yyin;
%}

%%

[ \t]	;
[\n]	{ yylineno = yylineno+1;}
	/* Keywords */
"int"	{ printf("LineNum: %d Type: KEYWORD Token: %s\n",yylineno,yytext);return INT;}
"unsigned int"	{ printf("LineNum: %d Type: KEYWORD Token: %s\n",yylineno,yytext);return UINT;}
"float"			{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return FLOAT;}
"main"		{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return MAIN;}
"char"	{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return CHAR;}
"for"	{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return FOR;}
"if"	{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return IF;}
"else"	{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return ELSE;}
"while"	{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return WHILE;}
"switch"	{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return SWITCH;}
"break"	{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return BREAK;}
"default"	{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return DEFAULT;}
"case"	{ printf("LineNum: %d Type: KEYWORD Token:%s\n",yylineno,yytext);return CASE;}
"void"	{printf("LineNum: %d Type: KEYWORD Token: %s\n",yylineno,yytext);return VOID;}
"struct"	{printf("LineNum: %d Type: KEYWORD Token: %s\n",yylineno,yytext);return STRUCT;}
"printf"	{printf("LineNum: %d Type: KEYWORD Token: %s\n",yylineno,yytext);return PRINTF;}
"scanf"		{printf("LineNum: %d Type: KEYWORD Token: %s\n",yylineno,yytext);return SCANF;}
"return"	{printf("LineNum: %d Type: KEYWORD Token: %s\n",yylineno,yytext);return RETURN;}

^"#include".*	;

	/*Identifiers*/
{alphabet}({alphabet}|{digit})*	{printf("LineNum: %d Type: IDENTIFIER Token: %s\n",yylineno,yytext);return ID;}

	/*Integer Literal*/
{digit}+	{printf("LineNum: %d Type: INT LITERAL Token: %s\n",yylineno,yytext);yylval=atoi(yytext);return DIG;}	
({digit}*\.{digit}+) {printf("LineNum: %d Type: FLOAT LITERAL Token: %s\n",yylineno,yytext);yylval=atoi(yytext);return REAL;}
	
	/*Special Characters*/
"{"     {printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);c++;top++;scopestack[top]=c;return LBRACE;}
"}"		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);top--;return RBRACE;}
"["		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return LSQ;}
"]"		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return RSQ;}
";"		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return SEMICOLON;}
"("		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return LPAREN;}
")"		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return RPAREN;}
"&"		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return AND;}
"|"		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return OR;}
"!"		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return NOT;}
","		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return COMMA;}
"."		{printf("LineNum: %d Type: SPECIAL CHARACTER Token: %s\n",yylineno,yytext);return DOT;}
"%s"	{printf("LineNum: %d Type: FORMAT SPECIFIER Token: %s\n",yylineno,yytext);return SFORMAT;}
"%d"	{printf("LineNum: %d Type: FORMAT SPECIFIER Token: %s\n",yylineno,yytext);return DFORMAT;}
"%f"	{printf("LineNum: %d Type: FORMAT SPECIFIER Token: %s\n",yylineno,yytext);return FFORMAT;}
	/*Operators*/
"+"	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return ADD;}
"-"	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return SUB;}
"*"	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return MUL;}
"%"	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return DIV;}
"="	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return ASSIGN;}
"=="	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return ISEQ;}
">="	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return GEQ;}
"<="	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return LEQ;}
">"	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return GT;}
"<"	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return LT;}
"&&"	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return DAND;}
"||"	{printf("LineNum: %d Type: OPERATOR Token: %s\n",yylineno,yytext);return DOR;}

	/*Comments*/
\/\/.*	;
\/\*(.*\n)*.*\*\/	;
\"([^"])*\"		{printf("LineNum: %d Type: STRING Token: %s\n",yylineno,yytext);return STRING;}
%%

int yywrap(void)
{
	return 1;
}









































