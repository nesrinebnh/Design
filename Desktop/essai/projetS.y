%{
	#include<stdio.h>
	#include<string.h>
	#include"Routine.h"
	extern FILE *yyin;
	extern int line;
	extern int colonne;
	int yylex();
	int yyerror(char* msg);
	
	int type;
	int valeur;
	char op;
	
%}
%union{
	char *chaine;
	int entier;
	float reel;
}
%token '&' '|' '!' '>' '<' subEgal infEgal doubleEgal notEgal '+' '-' '*' '/' '=' ')' '(' ';' ',' IF ELSE ENDIF FOR ENDFOR Uint Ufloat DEC INST FIN 
%token <chaine> idf Define Commentaire
%token <entier> Int 
%token <reel> reel

%left '+' '-'
%left '*' '/'
%left '|' '&' 
%right '(' '!' ENDFOR ENDIF ELSE
%left '>' subEgal doubleEgal notEgal infEgal '<' 

%type <entier> Value 
%type <entier> ExpArithmetique

%%
S: entite DEC Dec INST Inst FIN {printf("programme correcte\n");YYACCEPT;}
;
entite : idf {printf("le nom du programme %s\n",$1);}
;
Dec : DecVar Dec 
	| DecCste Dec 
	| DecVar 
	| DecCste 
;
DecVar : Type listP ';' { }
;
DecCste : Define Type listC ';' { }
;
Type: Uint {type = 0; }
	| Ufloat {type = 1; }
;
listP: idf ',' listP {  insert($1,type,0); }
	| idf { insert($1,type,0); }
;
listC : idf '=' Value ',' listC  {  insert($1,type,1); compatible_type( idf_type($1) ,$3);  }
	| idf '=' Value {  insert($1,type,1); compatible_type( idf_type($1) ,$3);  }
;
Value : Int { valeur = $1; $$ = 0; }
	| reel { if( $1 == 0) valeur = 0; else valeur = -1;  $$ = 1; }
;
Inst : Affectation  ';' Inst  | Affectation  ';'
	 | Condition Inst | Condition
	 | Boucle Inst | Boucle
	 | Commentaire Inst | Commentaire
;
Affectation : idf '=' ExpArithmetique { non_dec($1); modif_cste($1); op = '=';  compatible_type( idf_type($1) ,$3);   }
;
ExpArithmetique: idf OpArithmetique ExpArithmetique  { non_dec($1); compatible_type( idf_type($1) ,$3); $$ = idf_type($1);  }
					  | Value OpArithmetique ExpArithmetique { compatible_type($1,$3); $$ = $1; }
					  | '(' ExpArithmetique ')' OpArithmetique ExpArithmetique { compatible_type($2,$5); $$ = $2;  }
					  | idf  { non_dec($1); $$ = idf_type($1);  }
					  | Value {  div_par_zero(op,valeur);  $$ = $1; }
					  | '(' ExpArithmetique ')' { $$ = $2; }
;
OpArithmetique: '+'  {op = '+';}
	| '-'  {op = '-';}
	| '*'  {op = '*';}
	| '/'  {op = '/'; }
;
Condition: IF '(' Expression ')' Inst ENDIF
		 | IF '(' Expression ')' Inst  ELSE Inst ENDIF
;
Expression: EXPComparaison | ExpressionLogique
;
EXPComparaison: ExpArithmetique OPComparaison ExpArithmetique { compatible_type( $1 ,$3); }
;
OPComparaison: '>' 
					| '<' 
					| subEgal 
					| infEgal 
					| doubleEgal 
					| notEgal 
; 
ExpressionLogique: '(' Expression ')' OperateurLogique '(' Expression ')'  
					| '!' '(' Expression ')'
;
OperateurLogique : '&' | '|' 
;
Boucle : FOR '(' Affectation ';' '(' Expression ')' ';' Affectation ')' Inst ENDFOR 
;

%%
int yyerror(char* msg)
{printf("%s: ligne %d,colonne %d.\n",msg,line,colonne);
return 1;
}
int main()
{

yyin=fopen("code.txt","r");
yyparse();
display();

return 0;
}




