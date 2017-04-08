%{
#include <bits/stdc++.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include "symboltable.cpp"
extern "C" {
		int yylex(void);
		void yyerror(char *);
	}
extern char idname[10000];
extern int c;
extern int scopestack[100],top;
extern FILE *yyin;
%}

%token INT UINT FLOAT CHAR STRING ID DIG REAL
%token FOR IF ELSE WHILE SWITCH BREAK CASE DEFAULT VOID STRUCT SCANF PRINTF RETURN MAIN
%token LBRACE RBRACE LSQ RSQ LPAREN RPAREN SEMICOLON COMMA DOT COLON SFORMAT DFORMAT FFORMAT
%token AND NOT OR
%token ADD SUB MUL DIV ASSIGN
%token ISEQ GT LT GEQ LEQ DAND DOR
%name parse
%left ADD SUB
%left MUL DIV
%left GT LT GEQ LEQ ISEQ
%left AND OR
%left DAND DOR
%right ASSIGN
%left ELSE
%start mainfunction
%%

mainfunction:
			INT MAIN LPAREN RPAREN statements
			| VOID MAIN LPAREN RPAREN statements
			;
statements:
			LBRACE statementlist RBRACE
			;
statementlist:
			statementlist statement
			| statement
			;
statement   :
			expressionstatement
			|returnstatement
			| forstatement
			| whilestatement
			| ifstatement
			| declarationstatement
			;

expressionstatement:
					SEMICOLON
					| expression SEMICOLON
					| expression COMMA expression SEMICOLON
					;
returnstatement:
			RETURN expression SEMICOLON
			;
expression:
			DIG
			| REAL
			| identifier
			| identifier ASSIGN expression
			| arrayindex
			| arrayindex ASSIGN expression
			| expression ADD expression
			| expression SUB expression
			| expression MUL expression
			| expression DIV expression
			| expression GT expression
			| expression LT expression
			| expression GEQ expression
			| expression LEQ expression
			| expression DAND expression
			| expression DOR expression
			| expression ISEQ expression
			| LPAREN expression RPAREN
			;
whilestatement :
				WHILE LPAREN expression RPAREN statements
				;
opexpstmt :
				expression
				| expression COMMA expression
				;
forstatement  :
				FOR LPAREN opexpstmt SEMICOLON opexpstmt SEMICOLON opexpstmt RPAREN statements
				;
ifstatement :
				IF LPAREN expression RPAREN statements elsestatement
				;
elsestatement :
				ELSE statements
				|
				;
identifier:
			ID
			;
arrayindex :
			TYPE LSQ expression RSQ
			;
TYPE :
		INT
		| FLOAT
		| UINT
		;

declarationintstub:
				ID
				{
				insert("y",INT,scopestack[top],0);
				}
				| decarrayindex
				| ID ASSIGN expression
				{
				insert("x",INT,scopestack[top],4);
				}
				;

declarationfloatstub:
				ID
				{
				insert(idname,FLOAT,scopestack[top],0.0);
				}
				| decarrayindex
				| ID ASSIGN expression
				{
				insert(idname,FLOAT,scopestack[top],$3);
				}
				;

decarrayindex : ID LSQ DIG RSQ
				;

declarationlistint:
				COMMA declarationintstub declarationlistint
				|
				;

declarationlistfloat:
				COMMA declarationfloatstub declarationlistfloat
				|
				;

declarationstatement:
					INT declarationintstub declarationlistint SEMICOLON
					| FLOAT declarationfloatstub declarationlistfloat SEMICOLON
					;

%%
void yyerror(char* s){
	fprintf(stderr,"%s",s);
}
int main(int argc, char *argv[])
{
	yyin = fopen(argv[1],"r");
	yyparse();
	fclose(yyin); 
}

						