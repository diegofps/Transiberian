%{ 
	
%}

%option yylineno

DELIM		[\n\t ]
NUMERO		[0-9]
LETRA		[a-zA-Z_]
TRUE		"verdadeiro"
FALSE		"falso"
CTE_BOOL	{TRUE}|{FALSE}
CTE_ID		{LETRA}({LETRA}|{NUMERO})*
CTE_INT		{NUMERO}({NUMERO})*
CTE_DOUBLE	{NUMERO}({NUMERO})*([.]({NUMERO})*)?
CTE_CHAR	\'.\'
CTE_STRING	\"[^"]*\"
CTE_COMMENT	\%\%([^{\%}{\%}])*\%\%

%%

"inteiro"	{ yylval = Atributos(yytext, tipo()); return TK_INTEIRO; }
"caractere"	{ yylval = Atributos(yytext, tipo()); return TK_CARACTER; }
"duplo"		{ yylval = Atributos(yytext, tipo()); return TK_DUPLO; }
"flutuante"	{ yylval = Atributos(yytext, tipo()); return TK_FLUTUANTE; }
"linha"		{ yylval = Atributos(yytext, tipo()); return TK_LINHA; }
"booleano"	{ yylval = Atributos(yytext, tipo()); return TK_BOOLEANO; }
"vazio"		{ yylval = Atributos(yytext, tipo()); return TK_VAZIO; }
"aleatorio"	{ yylval = Atributos(yytext, tipo()); return TK_ALEATORIO; }
"const"		{ yylval = Atributos(yytext, tipo()); return TK_CONST; }
"&"		{ yylval = Atributos(yytext, tipo()); return TK_REF; }

"$"		{ yylval = Atributos(yytext, tipo()); return TK_RETORNO; }
"entrada"	{ yylval = Atributos(yytext, tipo()); return TK_ENTRADA; }
"saida"		{ yylval = Atributos(yytext, tipo()); return TK_SAIDA; }
"+"		{ yylval = Atributos(yytext, tipo()); return TK_MAIS; }
"-"		{ yylval = Atributos(yytext, tipo()); return TK_MENOS; }
"*"		{ yylval = Atributos(yytext, tipo()); return TK_VEZES; }
"/"		{ yylval = Atributos(yytext, tipo()); return TK_DIVISAO; }
"^"		{ yylval = Atributos(yytext, tipo()); return TK_EXP; }
"%"		{ yylval = Atributos(yytext, tipo()); return TK_MOD; }

"!"		{ yylval = Atributos(yytext, tipo()); return TK_NAO; }
">"		{ yylval = Atributos(yytext, tipo()); return TK_MAIOR; }
"<"		{ yylval = Atributos(yytext, tipo()); return TK_MENOR; }
"="		{ yylval = Atributos(yytext, tipo()); return TK_IGUAL; }
">="		{ yylval = Atributos(yytext, tipo()); return TK_MAIOR_IGUAL; }
"<="		{ yylval = Atributos(yytext, tipo()); return TK_MENOR_IGUAL; }
"!="		{ yylval = Atributos(yytext, tipo()); return TK_NAO_IGUAL; }
"&&"		{ yylval = Atributos(yytext, tipo()); return TK_E; }
"||"		{ yylval = Atributos(yytext, tipo()); return TK_OU; }
"^^"		{ yylval = Atributos(yytext, tipo()); return TK_XOU; }

">>"		{ yylval = Atributos(yytext, tipo()); return TK_MAIOR_MAIOR; }
"<<"		{ yylval = Atributos(yytext, tipo()); return TK_MENOR_MENOR; }
"?"		{ yylval = Atributos(yytext, tipo()); return TK_SE; }
"!>"		{ yylval = Atributos(yytext, tipo()); return TK_SENAO; }
"->"		{ yylval = Atributos(yytext, tipo()); return TK_FACA; }
"V"		{ yylval = Atributos(yytext, tipo()); return TK_PARATODO; }
"E"		{ yylval = Atributos(yytext, tipo()); return TK_PERTENCENTE; }

{DELIM}		{ }
{CTE_COMMENT}	{ }
{CTE_INT}	{ yylval = Atributos(yytext, tipo('i')); return CTE_INT; }
{CTE_DOUBLE}	{ yylval = Atributos(yytext, tipo('d')); return CTE_DOUBLE; }
{CTE_BOOL}	{ yylval = Atributos(yytext, tipo('b')); return CTE_BOOL; }
{CTE_CHAR}	{ yylval = Atributos(yytext, tipo('s')); return CTE_CHAR; }
{CTE_STRING}	{ yylval = Atributos(yytext, tipo('s')); return CTE_STRING; }
{CTE_ID}	{ yylval = Atributos(string("_")+yytext, tipo()); return CTE_ID; }

.		{ return *yytext; }

%%

