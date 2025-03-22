%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "calc.tab.h"

%}

	/*very similar to the lex in hw2. I*/
	/*removed all the error checking*/
	/*and added relevant characters to be*/
	/*returned.*/

ALPHABET   [a-zA-Z]+
DIGIT      [0-9]*
ALNUM      [a-zA-Z0-9]
IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*
INTEGER    0|[1-9][0-9]*
DEC        {DIGIT}*"."{DIGIT}*
SCIDEC     {DEC}[eE][+-]?[INTEGER]+
OP         [-+*/^]
OPERAND    {INTEGER}|{DEC}

%%

{IDENTIFIER} { yylval.id = strdup(yytext); return identifier; }
{OPERAND}    { yylval.num = atof(yytext); return number; }
[ \t]+       ;
\n           { return '\n'; }
[=]          { return '='; }
{OP}         { return yytext[0]; }
[()]         { return yytext[0]; }
	/*General error checking if tomfoolery occurs.*/
.            { printf("Unexpected character: %s\n", yytext); }

%%

int yywrap() {
    return 1;
}
