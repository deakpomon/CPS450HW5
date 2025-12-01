%{
#include <stdio.h>
#include <stdlib.h>

FILE *yyin;
FILE *yyout;
%}

%option noyywrap

%x COMMENT   /* start condition for multiline comments */

%%

/* ---------- comments ---------- */

/* inline comment: // until end of line */
"//"[^\n]* {
    fprintf(yyout, "Inline-comment-%s\n", yytext);
}

/* multiline comment: /* ... */ */
"/*" {
    fprintf(yyout, "Open-multiline-comment\n");
    BEGIN(COMMENT);
}

<COMMENT>"*/" {
    fprintf(yyout, "Close-multiline-comment\n");
    BEGIN(INITIAL);
}

<COMMENT>.      { /* ignore comment content */ }
<COMMENT>\n     { /* ignore newlines inside comments */ }

/* ---------- keywords and booleans ---------- */

"int"           { fprintf(yyout, "Keyword-int\n"); }
"bool"          { fprintf(yyout, "Keyword-bool\n"); }
"float"         { fprintf(yyout, "Keyword-float\n"); }
"char"          { fprintf(yyout, "Keyword-char\n"); }
"if"            { fprintf(yyout, "Keyword-if\n"); }
"while"         { fprintf(yyout, "Keyword-while\n"); }

"true"          { fprintf(yyout, "Boolean-true\n"); }
"false"         { fprintf(yyout, "Boolean-false\n"); }

/* ---------- numbers ---------- */

/* floats must come before integers */
[0-9]+"."[0-9]+ {
    fprintf(yyout, "Float-%s\n", yytext);
}

[0-9]+ {
    fprintf(yyout, "Integer-%s\n", yytext);
}

/* ---------- comparison and assignment ---------- */

/* multi char comparisons first */
"<="|">="|"=="|"!="|"<"|">" {
    fprintf(yyout, "Comparison-%s\n", yytext);
}

/* assignment single = */
"=" {
    fprintf(yyout, "Assignment\n");
}

/* ---------- operators ---------- */

"+"|"-"|"*"|"/"|"%" {
    fprintf(yyout, "Operator-%s\n", yytext);
}

/* ---------- parentheses and braces ---------- */

"(" { fprintf(yyout, "Open-paren\n"); }
")" { fprintf(yyout, "Close-paren\n"); }
"{" { fprintf(yyout, "Open-bracket\n"); }
"}" { fprintf(yyout, "Close-bracket\n"); }

/* ---------- semicolon ---------- */

";" { fprintf(yyout, "Semicolon\n"); }

/* ---------- identifiers ---------- */

/* identifier: letter followed by letters or digits */
[a-zA-Z][a-zA-Z0-9]* {
    fprintf(yyout, "Identifier-%s\n", yytext);
}

/* ---------- char literal (optional) ---------- */

/* single printable character between quotes */
'\''[^\n']'\'' {
    fprintf(yyout, "Char-%s\n", yytext);
}

/* ---------- whitespace and everything else ---------- */

[ \t\r\n]+  { /* ignore whitespace */ }

.           { /* ignore any other single character */ }

%%

int main(int argc, char *argv[]) {
    FILE *fp;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s <inputfile>\n", argv[0]);
        return 1;
    }

    fp = fopen(argv[1], "r");
    if (!fp) {
        perror("Error opening input file");
        return 1;
    }

    yyin = fp;
    yyout = fopen("output.txt", "w");
    if (!yyout) {
        perror("Error opening output file");
        fclose(fp);
        return 1;
    }

    yylex();

    fclose(fp);
    fclose(yyout);
    return 0;
}
