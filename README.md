```markdown
# Calculator with Flex & Bison

## Flex / Bison vs. Flex Evaluation

Flex alone is very limited in its implementation. For example, it could not handle multiple expressions like:

```txt
3 + 3 + 3
```

Unless explicitly specified, Flex can't parse recursive structures. This is because Flex doesn't support grammar rules. All recursion and complex logic were implemented with **Bison**.

In this project, Flex simply returns tokens, while Bison handles the grammar and parsing. This structure enables support for complex expressions, operator precedence, and nested statements — all features that Flex alone cannot support.

The more complex the grammar, the more necessary it is to have mechanisms like **operator precedence** — something Bison handles and Flex cannot.

---

## BNF Grammar Rules

> The grammar is mostly implemented in code, but here's an overview.

- The top-level rule is `stmt_list`, which can contain a single `stmt` or multiple ones.
- The `stmt` rule supports expressions, assignments, and error recovery.
- Assignments are of the form `identifier = expr`.
- `expr` is the most involved rule and handles:
  - Mathematical operations
  - Parentheses
  - Unary operators
  - Error checking (e.g., division by zero)

### Grammar (Bison)

```bison
stmt_list:
      stmt
    | stmt_list stmt
;

stmt:
      '\n'
    | expr '\n'           { if (!std::isnan($1)) { printf("= %g\n>> ", $1); }}
    | identifier '=' expr '\n'
    | error '\n'          { yyerrok; yyclearin; std::cout << ">> "; }
;

expr:
      number                  { $$ = $1; }
    | identifier
    | '(' expr ')'            { $$ = $2; }
    | expr '^' expr           { $$ = pow($1, $3); }
    | expr '*' expr           { $$ = $1 * $3; }
    | expr '/' expr           { $$ = $1 / $3; }
    | expr '+' expr           { $$ = $1 + $3; }
    | expr '-' expr           { $$ = $1 - $3; }
    | '-' expr %prec UMINUS   { $$ = -$2; }
    | '+' expr %prec UPLUS    { $$ = $2; }
;
```

---

## Use of ChatGPT

I used **ChatGPT extensively** for this assignment — mostly for **debugging**.

When I ran into issues I couldn’t solve quickly, I provided ChatGPT with the code, input, and terminal output to help identify the problem. This saved a lot of time and frustration, especially since I tend to make small, hard-to-spot mistakes.

ChatGPT was useful for:
- Explaining Flex/Bison features (`YYERROR`, `yyclearin`, `yyerrok`)
- Understanding how error handling works
- Formatting this file into proper Markdown

However, it wasn't great at **implementing** things correctly. For example, its advice on error checking syntax led to more confusion than solutions. In those cases, I learned more by reviewing examples, like the MIT postfix calculator example.

---

## Files

- `calc.l` – Flex (Lexer) file
- `calc.y` – Bison (Parser) file
- `README.md` – You're reading it!

---

## Summary

Flex and Bison together form a powerful toolchain for building parsers and interpreters. Flex handles lexical analysis, and Bison manages the grammar and parsing logic — making it possible to build fully functioning calculators with support for complex expressions, variable assignment, and error checking.

```

