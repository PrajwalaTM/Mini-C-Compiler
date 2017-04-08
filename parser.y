%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int yylex(void);	
void yyerror(char*);
extern char idname[10000];
extern int stack[100],top,yylineno;
extern FILE *yyin;

void checkScope();
int hash_lookup_scope(char *);
void display_hash();
void reset_hash();
#define SIZE 1000
void insert_hash(char *,int,int,int);
struct DataItem 
{
  	char* text;   
  	int scope;
	int type;
	int arraysize;
};

struct DataItem* hashArray[SIZE]; 
struct DataItem* item;

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
%start program
%%

program: 	structstatement st functionstatement mainfunction
			;
st:	
	SEMICOLON
	|
	;
structstatement: 
				STRUCT ID statements
				|
				;
mainfunction:
			INT MAIN LPAREN RPAREN statements
			| VOID MAIN LPAREN RPAREN statements
			|
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
			{checkScope();}
			;

functionstatement: 
				INT ID LPAREN arglist RPAREN statements
				|
				FLOAT ID LPAREN arglist RPAREN statements
				|
				VOID ID LPAREN arglist RPAREN statements
				;
arglist:
		arg COMMA arg 
		;
arg:
	INT ID
	|
	FLOAT ID
	;
declarationintstub:
				ID
				{
				 insert_hash(idname,stack[top],INT,0);
				}
				| decarrayindexint 
				| ID ASSIGN expression
				{
				insert_hash(idname,stack[top],INT,0);
				}
				;

declarationfloatstub:
				ID
				 {insert_hash(idname,stack[top],FLOAT,0);}
				| decarrayindexfloat 
				| ID ASSIGN expression
				{
				insert_hash(idname,stack[top],FLOAT,0);
				}
				;

decarrayindexint : ID LSQ DIG RSQ
				{
				insert_hash(idname,stack[top],INT,yylval);
				}
				;
decarrayindexfloat : ID LSQ DIG RSQ
				{
				insert_hash(idname,stack[top],FLOAT,yylval);
				}
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

int i;


int hashCode(char* key) 
{
   unsigned int i,hash=7;
   for(i=0;i<strlen(key);++i)
   {
       hash=hash*31+key[i];
   }
   return hash % SIZE;
}


void insert_hash(char* text,int scope,int type,int arraysize) 
{

  
   int hashIndex = hashCode(text);

  

   while(hashArray[hashIndex] != NULL) 
   {
      if (strcmp(hashArray[hashIndex]->text,text) == 0 )
		{		
		if(hashArray[hashIndex]->scope==stack[top])
		{
		printf("Line:%d ERROR: Multiple declarations are not allowed.\n",yylineno);
		return;
		}
		}
      
      ++hashIndex;
		
      
      hashIndex %= SIZE;
   }
   
   int i;
   int len= strlen(text);
   hashArray[hashIndex] = (struct DataItem*)malloc(sizeof(struct DataItem));
   hashArray[hashIndex]-> scope = scope;
   hashArray[hashIndex]-> type = type;
   hashArray[hashIndex]-> arraysize= arraysize;
   hashArray[hashIndex]-> text = (char *)malloc(len*sizeof(char));
   strcpy(hashArray[hashIndex]->text,text);
}


void display_hash() 
{
   int i = 0;
	printf("Symbol Name\tScope\t\tType\t     Arraysize\n------------------------------------------------------\n");	
   for(i = 0; i<SIZE; i++) 
   {
      if(hashArray[i] != NULL)
	printf("%s\t\t%d\t\t%d\t\t%d\n",hashArray[i]->text,hashArray[i]->scope,hashArray[i]->type,hashArray[i]->arraysize);         
	
      
   }
	
   printf("\n");
}

void reset_hash()
{
int i;
for (i=0;i<SIZE;i++)
	hashArray[i] = NULL;
}

int hash_lookup_scope(char * key)
{
int hashIndex = hashCode(key);
while (hashArray[hashIndex]!=NULL)
	{
	if (strcmp(hashArray[hashIndex]->text,key)== 0 )
		{
		return hashArray[hashIndex]->scope;
		}
	hashIndex ++;
	hashIndex %= SIZE;	
	}
return -1;
}
void checkScope()
{
int varscope = hash_lookup_scope(idname);
//printf("Scope of %s is %d\n",idname,varscope);
int i;
int flag = 0;
if (top<0) printf("Line:%d ERROR:This should never happen.\n",yylineno);
for (i=0;i<=top;i++)
	{
	if (varscope == stack[i])
		{		
		flag=1;
		break;
		}
	}
if (!flag)
	printf("Line:%d ERROR:Scope Error\n",yylineno);
}
void yyerror(char* s){
	fprintf(stderr,"%s",s);
}
int main(int argc, char *argv[])
{
	yyin = fopen(argv[1],"r");
	reset_hash();
	yyparse();
	display_hash();
	fclose(yyin); 
}

						