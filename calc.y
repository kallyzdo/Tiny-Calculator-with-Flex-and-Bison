//I am not sure how to write the BNF rules here. They are pretty
//exactly described in the code. 
//stmt_list produces either stmt or stmt_list.
//There is one main rule called stmt. From here we get either an assigment
//or an expression. The assignment rule is defined directly under stmt. This
//is so that errors under expression get resolved before the assignment takes
//place.
//Assignment is pretty simple, because it takes the form Identifer = expr
//and that form alone. There are some checks to make sure that the expr
//to be assigned does not return an error.
//expr is the meatiest of the three. This is because the expression rule is 
//how everything is handled. It needs the terminal number which is a token
//that is returned by lex when it sees an operand as specified in calc.l. The
//identifier, returned the same way, returns NAN if the variable has not been
//assigned previously. The rest of the rules for expr handle the different
//operations and scenarios with signs. There is error checking for division
//to ensure that no there is no dividing by zero.

%{
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <iostream>
#include <map>

//https://github.com/jengelsma/yacc-tutorial/blob/master/calc.y 


//function declarations for flex/bison
extern int yylex();
extern int yyparse();
extern void yyerror(const char* s);
//helper functions for the purpose
//of assigning variables
double getVar(std::string var);
void setVar(std::string var, double val);

//map for holding variables.
std::map<std::string, double> Variable; 

%}

%start stmt_list

//a union that holds either the number token
//or identifier token.
%union { double num; char* id; }

//defining the tokens.
%token <num> number
%token <id> identifier
//defining the types of the rules.
%type <num> expr 
//%type <id> assignment

//This is important for operator 
//precedence. PEMDAS.
%left '+' '-' 
%left '*' '/'
%right '^'
%left UMINUS UPLUS

%%

//The structure is taken from the postfix mit implementation.
//I had a structure before, but I wanted to try this for the 
//purpose of getting better error handling, as I have been
//struggling with getting it to work properly.

stmt_list:	stmt
			| stmt_list stmt
;


stmt:   '\n'
        | expr '\n' { if (!std::isnan($1)) { printf("= %g\n>> ", $1); }}  //only prints if valid
		
		//putting this rule under stmt gives expr precedence. This is so expr errors are caught
		//first.
		| identifier '=' expr '\n' {
			if (!std::isnan($3)) {
				setVar($1, $3);
				std::cout << std::string($1) << " is now equal to " << $3 << std::endl;
			} else {
				YYERROR;
			}
			std::cout << ">> ";
		}		
        | error '\n' {yyerrok; yyclearin; std::cout << ">> ";}	//direct YYERROR; here
;


expr: number                { $$ = $1; }
    | identifier            { 
		if (!std::isnan(getVar($1))) {
			$$ = getVar($1); 
		} else YYERROR; }
    | '(' expr ')'          { $$ = $2; }              
    | expr '^' expr         { $$ = pow($1, $3); }    
    | expr '*' expr         { $$ = $1 * $3; }        
    | expr '/' expr         { 
        if ($3 == 0) {
            yyerror("CANNOT DIVIDE BY ZERO");
			YYERROR;
			
        } else { $$ = $1 / $3; }}      
    | expr '+' expr         { $$ = $1 + $3; }        
    | expr '-' expr         { $$ = $1 - $3; } 
    | '-' expr %prec UMINUS { $$ = -$2; }
    | '+' expr %prec UPLUS  { $$ = $2; }
    ;

%%

double getVar(std::string var) {
	
	//.find() returns the end if there is no already
	//existing entry.
	if (Variable.find(var) != Variable.end()) {
		return Variable[var];
		
	} else {
		//For error checking. If a variable that has not been
		//assigned is used, it will print an error.
		yyerror("VARIABLE NOT RECOGNIZED");
		//returning NAN is important for the conditionals in the BNF
		//under stmt.
		return NAN;
	}
}

void setVar(std::string var, double val) {
	
	//If there is already an entry with var as key,
	//then we will update it with the new assignment.
	if (Variable.find(var) != Variable.end()) {
		Variable[var] = val;
		return;
		
	//else we add it to the map.	
	} else {
		Variable.emplace(var, val);
		return;
	}
}

int main() {
	printf(">> ");
    yyparse();
    return 0;
}

void yyerror(const char* s) {
    std::cout << "ERROR: " << s << "\n";
}