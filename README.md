## Flex / Bison vs Flex Evaluation

Flex was very limited in its implementation. It could not handle multiple expressions. 3 + 3 + 3 could not be parsed unless specified directly. This is because flex doesn't have grammar rule. All of these things that have to do with recursion were implemented with Bison. In that implementation flex really took a more laidback role and simply returned tokens for bison to use. 
This also allowed for more complex operations such as more than one operator in an expression. The more complex the "grammar" gets, the more of a need there will be for certain checks. One of these checks that ensure the functionality of the calculator is the operator precedence. This is a functionality of bison and probably is impossible with flex.

---
## BNF Grammar Rules

I am not sure how to write the BNF rules here. They are pretty
exactly described in the code. 
stmt_list produces either stmt or stmt_list.
There is one main rule called stmt. From here we get either an assigment
or an expression. The assignment rule is defined directly under stmt. This
is so that errors under expression get resolved before the assignment takes
place.
Assignment is pretty simple, because it takes the form Identifer = expr
and that form alone. There are some checks to make sure that the expr
to be assigned does not return an error.
expr is the meatiest of the three. This is because the expression rule is 
how everything is handled. It needs the terminal number which is a token
that is returned by lex when it sees an operand as specified in calc.l. The
identifier, returned the same way, returns NAN if the variable has not been
assigned previously. The rest of the rules for expr handle the different
operations and scenarios with signs. There is error checking for division
to ensure that no there is no dividing by zero.

```bison

stmt_list: stmt
         | stmt_list stmt
;


stmt:   '\n'
        | expr '\n' { if (!std::isnan($1)) { printf("= %g\n>> ", $1); }}
        | identifier '=' expr '\n'	
        | error '\n' {yyerrok; yyclearin; std::cout << ">> ";}
;


expr: number                { $$ = $1; }
    | identifier            
    | '(' expr ')'          { $$ = $2; }              
    | expr '^' expr         { $$ = pow($1, $3); }    
    | expr '*' expr         { $$ = $1 * $3; }        
    | expr '/' expr         { $$ = $1 / $3; }}      
    | expr '+' expr         { $$ = $1 + $3; }        
    | expr '-' expr         { $$ = $1 - $3; } 
    | '-' expr %prec UMINUS { $$ = -$2; }
    | '+' expr %prec UPLUS  { $$ = $2; }
    ;
	
```
---
	
### Use of ChatGPT

I used ChatGPT extensively for this assignment. Mostly for debugging. I really don't want to spend hours trying to figure out every little bug, especially since I am prone to rather stupid mistakes. So if I can't figure it out quickly, I give ChatGPT the code and the input and error and the terminal and I have it identify the issue. This is saves me much frustration and time.

I think it's okay with explaining concepts or features within flex or bison, but it fails at properly implementing it. I realized this when trying to debug the error checking. It could tell me about YYERROR, yyclearin, and yyerrok, which I used for error checking, but the way it told me how it fits in code confused me and led to more errors. Here I learned more looking at the technique of the MIT postfix example.
