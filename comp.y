/*
	Descrição:	Trabalho final de compiladores
	
	Autores:	Diego Fonseca Pereira de Souza.		DRE: 108055513
			Gustavo Rodrigues Lima.			DRE: 108055416
			Paula Soares Loureiro			DRE: 108056218
*/

%{
	#include <string>
	#include <map>
	#include <iostream>
	#include <vector>
	#include <stdlib.h>
	#include <string.h>
	
	enum tipo{i,c,s,f,b,d,v};
	
	int yylex();
	int yyparse();
	void yyerror(const char *s);
	
	using namespace std;
	
	struct VarTemp {
		int nInt, nDouble, nChar, nString, nBool, nRotulo, nStringPointer;
		
		VarTemp():nInt(0),nDouble(0),nChar(0),nString(0),nBool(0),nRotulo(0),nStringPointer(0){};
	} varTemp;
	
	struct Tipo {
		tipo base;
		int d1, d2;
		bool lv;
		bool cte;
		bool ref;
		bool cabecalho;
		
		Tipo():base(),d1(0),d2(0),lv(false),cte(false),ref(false),cabecalho(false) {}
		
		Tipo(const Tipo &T):base(T.base),d1(T.d1),d2(T.d2),lv(T.lv),cte(T.cte),ref(T.ref),cabecalho(T.cabecalho) {}
		
		Tipo(tipo Base):base(Base), d1(0), d2(0),
			lv(false),cte(false),ref(false),cabecalho(false) {}
		
		Tipo(tipo Base, int D1):base(Base), d1(D1), d2(0),
			lv(false),cte(false),ref(false),cabecalho(false) {}
		
		Tipo(tipo Base, int D1, int D2):base(Base), d1(D1), d2(D2),
			lv(false),cte(false),ref(false),cabecalho(false) {}
		
		Tipo(tipo Base, int D1, int D2, bool Cte, bool Ref):base(Base), d1(D1), d2(D2),
			lv(false),cte(Cte),ref(Ref),cabecalho(false) {}
		
		Tipo(tipo Base, bool lValue, bool constante = false,
			bool referencia = false):base(Base),d1(0),d2(0),
			lv(lValue),cte(constante),ref(referencia),cabecalho(false) {}
		
		string getBase() {
			if (base == tipo('i'))      return "i";
			else if (base == tipo('c')) return "c";
			else if (base == tipo('s')) return "s";
			else if (base == tipo('f')) return "f";
			else if (base == tipo('b')) return "b";
			else if (base == tipo('d')) return "d";
			else if (base == tipo('v')) return "v";
			else                        return "";
		}
		
		bool operator == (const Tipo &b) {
			return	base == b.base &&
				d1 == b.d1 &&
				d2 == b.d2 &&
				lv == b.lv &&
				cte == b.cte;
		}
	};
	
	typedef struct _Atributos {
		string c,v;
		Tipo t;
		vector<Tipo> args;
		vector<string> vars;
		
		_Atributos():c(),v(),t(),args() {}
		_Atributos(string V, const tipo &T):c(),v(V),t(T),args() {}
	} Atributos;
	
	typedef struct _BOXLV {
		map<string, Tipo *> LV;
		_BOXLV *ant;
		
		_BOXLV():LV(),ant(NULL) {}
	} BOXLV;
	
	vector<Tipo> params;
	
	typedef struct _FUNCAO {
		Tipo retorno;
		vector<Tipo> param;
		bool corpo;
		bool cabecalho;
		
		_FUNCAO(Tipo RETORNO):retorno(RETORNO),param(params),corpo(false),cabecalho(false) {};
	} Funcao;
	
	BOXLV *top;
	map<string, Funcao *> listaFuncoes;
	map<string, tipo> tabResOper;
	bool naMain;
	
	FILE *entrada, *saida;
	bool saidaTela = false;
	bool saidaArquivo = false;
	tipo tipoRetorno;
	bool retornou;
	string nomeArquivoSaida;
	string nomeArquivoEntrada;
	
	
	#define YYSTYPE Atributos
	
	void criaTabelaResultado();
	tipo resultado(string operador, Tipo op1, Tipo op2);
	void Erro(string s);
	void Erro2(string s);
	void erroVND(string nome);
	string geraTemp(Tipo T);
	string geraLabel(string nome);
	string geraTempStringPointer();
	string intToStr(int i);
	int strToInt(string s);
	void trataConversaoCharIntDoubleBoolToString(string *v, Atributos *SS, const Atributos *Sn);
	void testaParametrosCompativeis(string nome, vector<Tipo> c);
	Tipo verificaFuncao(string nome, vector<Tipo> args);
	void testaConstante(const string *nome, const Tipo *T);
	void testaDimensao0(const Tipo *t1);
	string geraCodigoTipo(const Tipo *T);
	string geraCodigoTipoRetorno(const Tipo *T);
	string geraCodigoTipoTransiberian(const Tipo *T);
	void geraCodigoChamaFuncao(Atributos *SS, const Atributos *S1, const Atributos *S4);
	void geraCodigoCabecalho(Atributos *SS, const Atributos *S3, const Atributos *S6, const Atributos *S8);
	string geraParamsFinais(const Atributos *S1, const Atributos *S4);
	void geraCodigoAtrib0D(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoAtrib1D(Atributos *SS, const Atributos *S1, const Atributos *S3, const Atributos *S6);
	void geraCodigoAtrib2D(Atributos *SS, const Atributos *S1, const Atributos *S3, const Atributos *S5, const Atributos *S8);
	void geraCodigoAtrib3D(Atributos *SS, const Atributos *S1, const Atributos *S3, const Atributos *S5,
		const Atributos *S7, const Atributos *S10);
	void geraCodigoForEach(Atributos *SS, const Atributos *S3, const Atributos *S5, const Atributos *S7, const Atributos *S8);
	void geraCodigoVarForEach(Atributos *SS, const Atributos *S1, const Atributos *S2, const Atributos *S3);
	void geraCodigoAdicao(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoSubtracao(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoMultiplicacao(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoDivisao(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoModulo(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoExponencial(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoE(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoOu(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoXou(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoMaior(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoMenor(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoMaiorIgual(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoMenorIgual(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoIgual(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoNao(Atributos *SS, const Atributos *S2);
	void geraCodigoMenosUnario(Atributos *SS, const Atributos *S2);
	void geraCodigoMaisUnario(Atributos *SS, const Atributos *S2);
	void geraCodigoNaoIgual(Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoOprGenerico(string opr, Atributos *SS, const Atributos *S1, const Atributos *S3);
	void geraCodigoOprRelacional(string opr, Atributos *SS, const Atributos *S1, const Atributos *S3);
	Tipo verificaArray0D(string nome);
	Tipo verificaArray1D(string nome);
	Tipo verificaArray2D(string nome);
	void aumentaNivelVariavel();
	void reduzNivelVariavel();
	string variaveisNaBOXLV();
	void insereVariavel(string nome, Tipo *T);
	Tipo *buscaVariavel(string nome);
	Funcao *buscaFuncao(string nome);
	void insereParam(string nome, Tipo *T);
	void insereFuncao(string nome, Tipo retorno, bool corpo, bool cabecalho);
	string declaraTemporarias();
	void escreveTela(string s);
	void escreveArquivo(string s);
	void mostrarSintaxe();
	
%}

%token CTE_ID CTE_INT CTE_BOOL CTE_DOUBLE CTE_STRING CTE_CHAR
%token TK_INTEIRO TK_FLUTUANTE TK_BOOLEANO TK_LINHA TK_VAZIO TK_CARACTER TK_DUPLO TK_CONST TK_REF
%token TK_RETORNO TK_ENTRADA TK_SAIDA TK_ALEATORIO
%token TK_MAIS TK_MENOS TK_VEZES TK_DIVISAO TK_EXP TK_MOD
%token TK_SE TK_SENAO TK_PARATODO TK_PERTENCENTE TK_FACA
%token TK_NAO TK_MAIOR TK_MENOR TK_IGUAL TK_MAIOR_IGUAL TK_MENOR_IGUAL TK_NAO_IGUAL TK_E TK_OU TK_XOU
%token  TK_MAIOR_MAIOR TK_MENOR_MENOR

%left		')'
%left		TK_MAIS TK_MENOS
%left		TK_VEZES TK_DIVISAO TK_MOD TK_MAIOR_MAIOR
%left TK_E TK_OU TK_XOU

%right		'('
%right		TK_EXP TK_NAO TK_MENOR_MENOR

%nonassoc	TK_IGUAL TK_MAIOR TK_MENOR TK_MAIOR_IGUAL TK_MENOR_IGUAL TK_NAO_IGUAL

%nonassoc	IFX
%nonassoc	TK_SENAO

%start I

%%
	I : S {
		$$.c = "#include<iostream>\n#include<stdio.h>\n#include<string.h>\n#include<stdlib.h>\n#include<time.h>\n#include<math.h>\n\nusing namespace std;\n\n" +
			$1.c;
		$$.t = Tipo();
		$$.v = "";
		if (saidaTela)
			escreveTela($$.c);
		if (saidaArquivo)
			escreveArquivo($$.c);
	}
	;
	
	S : VARIAVEIS S {
		$$.c = $1.c + $2.c;
		$$.v = "";
		$$.t = Tipo();
	}
	| FUNCAO S {
		$$.c = $1.c + $2.c;
		$$.v = "";
		$$.t = Tipo();
	}
	| {
		$$.c = "";
		$$.v = "";
		$$.t = Tipo();
	}
	;
	
	VARIAVEIS : VARIAVEIS ',' VAR {
		$$ = $1;
		insereVariavel( $3.v, new Tipo($1.t.base, $3.t.d1, $3.t.d2, $1.t.cte, $3.t.ref) );
	}
	| TIPO VAR {
		$$ = $1;
		insereVariavel( $2.v, new Tipo($1.t.base, $2.t.d1, $2.t.d2, $1.t.cte, $2.t.ref) );
	}
	;
	
	TIPO : CONST TK_INTEIRO {
		$$.c = "";
		$$.v = $2.v;
		$$.t = Tipo( tipo('i') );
		$$.t.cte = $1.t.cte;
	}
	| CONST TK_CARACTER {
		$$.c = "";
		$$.v = $2.v;
		$$.t = Tipo( tipo('c') );
		$$.t.cte = $1.t.cte;
	}
	| CONST TK_BOOLEANO {
		$$.c = "";
		$$.v = $2.v;
		$$.t = Tipo( tipo('b') );
		$$.t.cte = $1.t.cte;
	}
	| CONST TK_LINHA {
		$$.c = "";
		$$.v = $2.v;
		$$.t = Tipo( tipo('s') );
		$$.t.cte = $1.t.cte;
	}
	| CONST TK_DUPLO {
		$$.c = "";
		$$.v = $2.v;
		$$.t = Tipo( tipo('d') );
		$$.t.cte = $1.t.cte;
	}
	| CONST TK_FLUTUANTE {
		$$.c = "";
		$$.v = $2.v;
		$$.t = Tipo( tipo('f') );
		$$.t.cte = $1.t.cte;
	}
	;
	
	CONST : TK_CONST {
		$$.c = "";
		$$.c = "";
		$$.t = Tipo( tipo('v') );
		$$.t.cte = true;
	}
	| {
		$$.c = "";
		$$.c = "";
		$$.t = Tipo( tipo('v') );
	}
	;
	
	VAR : REF CTE_ID {
		$$.c = "";
		$$.v = $2.v;
		$$.t = Tipo( tipo('v') );
		$$.t.ref = $1.t.ref;
	}
	| REF CTE_ID '[' CTE_INT ']' {
		$$.c = "";
		$$.v = $2.v;
		$$.t = Tipo( tipo('v'), strToInt($4.v) );
		$$.t.ref = $1.t.ref;
	}
	| REF CTE_ID '[' CTE_INT ',' CTE_INT ']' {
		$$.c = "";
		$$.v = $3.v;
		$$.t = Tipo( tipo('v'), strToInt($4.v), strToInt($6.v) );
		$$.t.ref = $1.t.ref;
	}
	;
	
	REF : TK_REF {
		$$.c = "";
		$$.c = "";
		$$.t = Tipo( tipo('v') );
		$$.t.ref = true;
	}
	| {
		$$.c = "";
		$$.c = "";
		$$.t = Tipo( tipo('v') );
	}
	;
	
	FUNCAO : CABECALHO CORPO REDUZNIVELVARIAVEL {
		insereFuncao($1.v, $1.t, true, false);
		if (naMain) 
			$$.c = $1.c + "{\n" + "srand(time(NULL));\n" + declaraTemporarias() + $3.c + $2.c + "}\n";
		else
			$$.c = $1.c + "{\n" + declaraTemporarias() + $3.c + $2.c + "}\n";
		
		if ( (!retornou) && (tipoRetorno!=tipo('v')) )
			Erro("Funcao \"" + $1.v + "\" do tipo \"" + geraCodigoTipoTransiberian( new Tipo( tipoRetorno ) ) +
				"\" nao retornou nenhum valor.");
	}
	| CABECALHO REDUZNIVELVARIAVEL ';' {
		insereFuncao($1.v, $1.t, false, true);
		$$.c = $1.c + ";";
	}
	;
	
	CABECALHO : '{' AUMENTANIVELVARIAVEL PARAMS '}' TK_MAIOR_MAIOR CTE_ID TK_MAIOR_MAIOR TIPORETORNO {
		geraCodigoCabecalho(&$$, &$3, &$6, &$8);
	}
	| '{' '}' TK_MAIOR_MAIOR AUMENTANIVELVARIAVEL CTE_ID TK_MAIOR_MAIOR TIPORETORNO {
		geraCodigoCabecalho(&$$, &$1, &$5, &$7);
	}
	| TK_MAIOR_MAIOR AUMENTANIVELVARIAVEL CTE_ID TK_MAIOR_MAIOR TIPORETORNO {
		geraCodigoCabecalho(&$$, &$1, &$3, &$5);
	}
	;
	
	TIPORETORNO : TK_VAZIO {
		$$.c = "";
		$$.v = "";
		$$.t = Tipo( tipo('v'), 0, 0);
	}
	| TIPO {
		$$ = $1;
	}
	| TIPO '[' CTE_INT ']' {
		$$ = $1;
		$$.t.d1 = strToInt($3.v);
	}
	| TIPO '[' CTE_INT ',' CTE_INT ']' {
		$$ = $1;
		$$.t.d1 = strToInt($3.v);
		$$.t.d2 = strToInt($5.v);
	}
	;
	
	PARAMS : PARAM ',' PARAMS {
		$$.c = $1.c + ", " + $3.c;
	}
	| PARAM {
		$$.c = $1.c;
	}
	;
	
	PARAM : TIPO REF CTE_ID {
		$$.t = Tipo($1.t.base, 0, 0, $1.t.cte, $2.t.ref);
		if ($$.t.ref) {
			$$.v = "*" + $3.v;
			$$.c = geraCodigoTipo(&$1.t) + " " + $$.v;
			insereParam($3.v, new Tipo($$.t));
		} else {
			$$.v = $3.v;
			if ($$.t.base == tipo('s')) {
				$$.c = geraCodigoTipo(&$1.t) + " " + $3.v + "[256]";
			} else {
				$$.c = geraCodigoTipo(&$1.t) + " " + $3.v;
			}
			insereParam($$.v, new Tipo($$.t));	
		}
	}
	| TIPO REF CTE_ID '[' CTE_INT ']' {
		$$.t = Tipo($1.t.base, strToInt($5.v), 0, $1.t.cte, $2.t.ref);
		if ($$.t.ref) {
			$$.v = "*" + $3.v;
			$$.c = geraCodigoTipo(&$1.t) + " " + $$.v;
			insereParam($3.v, new Tipo($$.t));
		} else {
			$$.v = $3.v;
			if ($$.t.base == tipo('s')) {
				$$.c = geraCodigoTipo(&$1.t) + " " + $3.v + "[" + intToStr($$.t.d1 * 256) + "]";
			} else {
				$$.c = geraCodigoTipo(&$1.t) + " " + $2.v + "[" + intToStr($$.t.d1) + "]";
			}
			insereParam($$.v, new Tipo($$.t));
		}
	}
	| TIPO REF CTE_ID '[' CTE_INT ',' CTE_INT ']' {
		$$.t = Tipo($1.t.base, strToInt($5.v), strToInt($7.v), $1.t.cte, $2.t.ref);
		if ($$.t.ref) {
			$$.v = "*" + $3.v;
			$$.c = geraCodigoTipo(&$1.t) + " " + $$.v;
			insereParam($3.v, new Tipo($$.t));
		} else {
			$$.v = $3.v;
			if ($$.t.base == tipo('s')) {
				$$.c = geraCodigoTipo(&$1.t) + " " + $3.v + "[" + intToStr($$.t.d1 * $$.t.d2 * 256) + "]";
			} else {
				$$.c = geraCodigoTipo(&$1.t) + " " + $3.v + "[" + intToStr($$.t.d1 * $$.t.d2) + "]";
			}
			insereParam($$.v, new Tipo($$.t));
		}
	}
	;
	
	CORPO : '{' CMDS '}' {
		$$.v = "";
		$$.t = Tipo();
		$$.c = $2.c;
	}
	;
	
	CMDS : CMD CMDS {
		$$.c = $1.c + $2.c;
		$$.v = "";
		$$.t = Tipo();
	}
	| {
		$$.c = "";
		$$.v = "";
		$$.t = Tipo();
	}
	;
	
	CMD : ';' { $$ = $1; }
	| VARIAVEIS { $$ = $1; }
	| BLOCO { $$ = $1; }
	| ATRIBUICAO { $$ = $1; }
	| CHAMAFUNCAO { $$ = $1; }
	| CMD_IF { $$ = $1; }
	| CMD_FOR { $$ = $1; }
	| CMD_FOREACH { $$ = $1; }
	| CMD_WHILE { $$ = $1; }
	| CMD_DO_WHILE { $$ = $1; }
	| CMD_RETURN { $$ = $1; }
	| CMD_ENTRADA { $$ = $1; }
	| CMD_SAIDA { $$ = $1; }
	;
	
	BLOCO : '{' AUMENTANIVELVARIAVEL CMDS REDUZNIVELVARIAVEL '}' {
		$$.v = "";
		$$.t = Tipo();
		$$.c = "{\n" + $4.c + $3.c + "}\n";
	}
	;
	
	ATRIBUICAO : CTE_ID TK_MENOR_MENOR E ';' { geraCodigoAtrib0D(&$$, &$1, &$3); }
	| CTE_ID '[' E ']' TK_MENOR_MENOR E ';' { geraCodigoAtrib1D(&$$, &$1, &$3, &$6); }
	| CTE_ID '[' E ',' E ']' TK_MENOR_MENOR E ';' { geraCodigoAtrib2D(&$$, &$1, &$3, &$5, &$8); }
	| CTE_ID '[' E ',' E ',' E ']' TK_MENOR_MENOR E ';' { geraCodigoAtrib3D(&$$, &$1, &$3, &$5, &$7, &$10); }
	;
	
	CHAMAFUNCAO : CTE_ID TK_MENOR_MENOR '{' ARGS '}' ';' { geraCodigoChamaFuncao(&$$, &$1, &$4); }
	| CTE_ID TK_MENOR_MENOR '{' '}' ';' { geraCodigoChamaFuncao(&$$, &$1, &$3); }
	;
	
	ARGS : ARGS ',' E {
		$$.c = $1.c + $3.c;
		$$.v = "";
		$$.t = $1.t;
		$$.args = $1.args;
		$$.vars = $1.vars;
		$$.args.push_back($3.t);
		$$.vars.push_back($3.v);
	}
	| E {
		$$ = $1;
		$$.args.push_back($1.t);
		$$.vars.push_back($1.v);
	}
	;
	
	CMD_IF : TK_SE E TK_MAIOR_MAIOR CMD %prec IFX {
		string fim = geraLabel("L_IF_FIM_");
		$$.t = Tipo();
		$$.v = "";
		$$.c = $2.c +
			$2.v + " = ! " + $2.v + ";\n" +
			"if ( " + $2.v + " ) goto " + fim + ";\n" +
			$4.c +
			fim + ":;\n";
	}
	| TK_SE E TK_MAIOR_MAIOR CMD TK_SENAO CMD {
		string then = geraLabel("L_IF_THEN_");
		string fim = geraLabel("L_IF_FIM_");
		$$.t = Tipo();
		$$.v = "";
		$$.c = $2.c +
			"if ( " + $2.v + " ) goto " + then + ";\n" +
			$6.c +
			"goto " + fim + ";\n" +
			then + ":;\n" +
			$4.c +
			fim + ":;\n";
	}
	;
	
	CMD_FOR : '(' E TK_SE E TK_FACA E ')' CMD {
		string condicao = geraLabel("L_CONDICAO_");
		string faca = geraLabel("L_FACA_");
		$$.t = Tipo();
		$$.v = "";
		$$.c = $2.c + 
			"goto " + condicao + ";\n" +
			faca + ":;\n" +
			$8.c +
			$6.c +
			condicao + ":;\n" +
			$4.c +
			"if (" + $4.v + ") goto " + faca + ";\n";
	}
	;
	
	CMD_FOREACH : TK_PARATODO AUMENTANIVELVARIAVEL VARFOREACH TK_PERTENCENTE CTE_ID TK_FACA CMD REDUZNIVELVARIAVEL {
		geraCodigoForEach(&$$, &$3, &$5, &$7, &$8);
	}
	;
	
	VARFOREACH : TIPO REF CTE_ID { geraCodigoVarForEach(&$$, &$1, &$2, &$3); }
	;
	
	CMD_WHILE : TK_SE E TK_FACA CMD {
		string condicao = geraLabel("L_CONDICAO_");
		string faca = geraLabel("L_FACA_");
		$$.t = Tipo();
		$$.v = "";
		$$.c = "goto " + condicao + ";\n" +
			faca + ":;\n" +
			$4.c +
			condicao + ":;\n" +
			$2.c +
			"if (" + $2.v + ") goto " + faca + ";\n";
	}
	;
	
	CMD_DO_WHILE : TK_FACA CMD TK_SE E {
		string faca = geraLabel("L_FACA_");
		$$.t = Tipo();
		$$.v = "";
		$$.c = faca + ":;\n" +
			$2.c +
			$4.c +
			"if ( " + $4.v + " ) goto " + faca + ";\n";
	}
	;
	
	CMD_RETURN : TK_RETORNO E ';' {
		testaDimensao0(&$2.t);
		
		if ($2.t.base != tipoRetorno) {
			Erro("Esperado variavel do tipo \"" + geraCodigoTipoTransiberian( new Tipo( tipoRetorno ) ) +
				"\" mas foi encontrado \"" + geraCodigoTipoTransiberian(&$2.t) + "\".");
		}
		
		$$.t = $2.t;
		$$.c = $2.c;
		if ( $$.t.base == tipo('s') ) {
			$$.v = geraTempStringPointer();
			$$.c += $$.v + " = (char*) malloc( sizeof(char) * 256 );\n" +
				"strncpy( " + $$.v + ", " + $2.v + ", 255);\n" +
				"return " + $$.v + ";\n";
		} else {
			$$.v = geraTemp( $$.t );
			$$.c += $$.v + " = " + $2.v + ";\n" +
				"return " + $$.v + ";\n";
		}
		retornou = true;
	}
	| TK_RETORNO ';' {
		$$.t = Tipo( tipo('v') );
		$$.v = "";
		if ( tipo('v') != tipoRetorno ) {
			Erro("Esperado variavel do tipo \"" + geraCodigoTipoTransiberian( new Tipo( tipoRetorno ) ) +
				"\" mas foi encontrado \"" + geraCodigoTipoTransiberian( new Tipo( tipo('v') ) ) + "\".");
		}
		$$.c = "return;\n";
		retornou = true;
	}
	;
	
	CMD_ENTRADA : TK_ENTRADA TK_MAIOR_MAIOR '{' CTE_ID '}' ';' {
		Tipo t = verificaArray0D($4.v);
		if (t.base == tipo('b') ) {
			string temp = geraTemp( tipo('s') );
			$$.c = "cin >>" + temp + ";\n" +
				"if ( strncmp(" + temp + ", \"verdadeiro\", 255) == 0 || strncmp(" + temp +
					", \"sim\", 255) == 0 || strncmp(" + temp + ", \"s\", 255) == 0 )\n" +
				$4.v + " = 1;\n" +
				"else\n" +
				$4.v + " = 0;\n";
		} else  if ( t.base == tipo('s') ) {
			$$.c = "fgets( " + $4.v + ", 255, stdin);\n";
		} else {
			$$.c = "cin >>" + $4.v + ";\n";
		}
	}
	| TK_ENTRADA TK_MAIOR_MAIOR '{' CTE_ID '[' E ']' '}' {
		Tipo t = verificaArray1D($4.v);
		$$.c = $6.c;
		
		if ( t.base == tipo('b') ) {
			string temp = geraTemp( tipo('s') );
			$$.c += "cin >>" + temp + ";\n" +
				"if ( strncmp(" + temp + ", \"verdadeiro\", 255) == 0 || strncmp(" + temp +
					", \"sim\", 255) == 0 || strncmp(" + temp + ", \"s\", 255) == 0 )\n" +
				$4.v + "[" + $6.v + "] = 1;\n" +
				"else\n" +
				$4.v + "[" + $6.v + "] = 0;\n";
		} else if ( t.base == tipo('s') ) {
			string temp = geraTemp( tipo('s') );
			string indice = geraTemp( tipo('i') );
			$$.c += indice + " = " + $6.v + " * 256;\n" +
				"fgets( " + temp + ", 255, stdin);\n" +
				"strncpy(" + $4.v + " + " + indice + ", " + temp + ", 255);\n";
		} else {
			string temp = geraTemp(t.base);
			$$.c += "cin >>" + temp + ";\n" +
				$4.v + "[" + $6.v + "] = " + temp + ";\n";
		}
	}
	| TK_ENTRADA TK_MAIOR_MAIOR '{' CTE_ID '[' E ',' E ']' '}' {
		Tipo t = verificaArray2D($4.v);
		string indice = geraTemp( tipo('i') );
		$$.c = $6.c + $8.c;
		
		if ( t.base == tipo('b') ) {
			string temp = geraTemp( tipo('s') );
			$$.c += indice + " = " + $6.v + " * " + intToStr(t.d2) + ";\n" +
				indice + " = " + indice + " + " + $8.v + ";\n" +
				"cin >>" + temp + ";\n" +
				"if ( strncmp(" + temp + ", \"verdadeiro\", 255) == 0 || strncmp(" + temp +
					", \"sim\", 255) == 0 || strncmp(" + temp + ", \"s\", 255) == 0 )\n" +
				$4.v + "[" + indice + "] = 1;\n" +
				"else\n" +
				$4.v + "[" + indice + "] = 0;\n";
		} else if ( t.base == tipo('s') ) {
			string temp = geraTemp( t.base );
			$$.c += indice + " = " + $6.v + " * " + intToStr(t.d2) + ";\n" +
				indice + " = " + indice + " + " + $8.v + ";\n" +
				indice + " = " + indice + " * 256;\n" +
				"fgets( " + temp + ", 255, stdin);\n" +
				"strncpy(" + $4.v + " + " + indice + ", " + temp + ", 255);\n";
		} else {
			string temp = geraTemp( t.base );
			$$.c += indice + " = " + $6.v + " * " + intToStr(t.d2) + ";\n" +
				indice + " = " + indice + " + " + $8.v + ";\n" +
				"cin >> " + temp + ";\n" +
				$4.v + "[" + indice + "] = " + temp + ";\n";
		}
	}
	;
	
	CMD_SAIDA :TK_SAIDA TK_MENOR_MENOR '{' E '}' ';' {
		testaDimensao0(&$4.t);
		if ( $4.t.base == tipo('b') ) {
			$$.c = $4.c +
				"if (" + $4.v + ") cout << \"verdadeiro\";\n" +
				"else cout << \"falso\";\n";
		} else {
			$$.c = $4.c +
				"cout << " + $4.v + ";\n";
		}
	}
	;
	
	E :  E TK_MAIS E { geraCodigoAdicao(&$$,&$1,&$3); }
	| E TK_MENOS E { geraCodigoSubtracao(&$$,&$1,&$3); }
	| E TK_VEZES E { geraCodigoMultiplicacao(&$$,&$1,&$3); }
	| E TK_DIVISAO E  { geraCodigoDivisao(&$$,&$1,&$3); }
	| E TK_MOD E  { geraCodigoModulo(&$$,&$1,&$3); }
	| E TK_EXP E  { geraCodigoExponencial(&$$,&$1,&$3); }
	| E TK_E E { geraCodigoE(&$$,&$1,&$3); }
	| E TK_OU E { geraCodigoOu(&$$,&$1,&$3); }
	| E TK_XOU E { geraCodigoXou(&$$,&$1,&$3); }
	| E TK_MAIOR E { geraCodigoMaior(&$$,&$1,&$3); }
	| E TK_MENOR E { geraCodigoMenor(&$$,&$1,&$3); }
	| E TK_MAIOR_IGUAL E { geraCodigoMaiorIgual(&$$,&$1,&$3); }
	| E TK_MENOR_IGUAL E { geraCodigoMenorIgual(&$$,&$1,&$3); }
	| E TK_IGUAL E { geraCodigoIgual(&$$,&$1,&$3); }
	| E TK_NAO_IGUAL E { geraCodigoNaoIgual(&$$,&$1,&$3); }
	| '(' E ')' { $$ = $2; }
	| TK_NAO E { geraCodigoNao(&$$,&$2); }
	| TK_MENOS E { geraCodigoMenosUnario(&$$,&$2); }
	| TK_MAIS E { geraCodigoMaisUnario(&$$,&$2); }
	| ATRIBUICAO { $$ = $1; }
	| F { $$ = $1; }
	;
	
	F : CTE_INT {
		$$.c = "";
		$$.v = $1.v;
		$$.t = Tipo( tipo('i') );
	}
	| CTE_DOUBLE {
		$$.c = "";
		$$.v = $1.v;
		$$.t = Tipo( tipo('d') );
	}
	| CTE_CHAR {
		$$.c = "";
		$$.v = $1.v;
		$$.t = Tipo( tipo('c') );
	}
	| CTE_STRING {
		$$.c = "";
		$$.v = $1.v;
		$$.t = Tipo( tipo('s') );
	}
	| CTE_BOOL {
		$$.c = "";
		$$.t = Tipo( tipo('b') );
		if (strncmp("falso", $1.v.c_str(), 4) == 0)
			$$.v = "0";
		else
			$$.v = "1";
	}
	| CTE_ID {
		Tipo *t = buscaVariavel($1.v);
		if (t == NULL)
			erroVND($1.v);
		$$.t = *t;
		$$.c = "";
		if (t->ref)
			$$.v = "( *" + $1.v + ")";
		else
			$$.v = $1.v;
	}
	| CTE_ID '[' E ']' {
		Tipo *t = buscaVariavel($1.v);
		if (t == NULL)
			erroVND($1.v);
		if ( $3.t.base != tipo('i') )
			Erro("Indice de array deve ser um inteiro.");
		if ( t->d1 > 0 && t->d2 == 0 ) {
			$$.t = Tipo( t->base);
			$$.v = geraTemp($$.t);
			$$.c = $3.c;
			
			if ( t->base == tipo('s') ) {
				string indice = geraTemp( tipo('i') );
				
				$$.c += indice + " = " + $3.v + " * 256;\n" +
					"strncpy(" + $$.v + ", " + $1.v + " + " + indice + ", 255);\n";
			} else {
				$$.c += $$.v + " = " + $1.v + "[" + $3.v + "];\n";
			}
		} else {
			if ( ( t->d1 == 0 && t->d2 == 0 ) && t->base == tipo('s') ) {
				$$.t = Tipo( tipo('c') );
				$$.v = geraTemp($$.t);
				$$.c = $3.c +
					$$.v + " = " + $2.v + "[" + $3.v + "];\n";
			} else {
				Erro("Variavel não é um vetor de dimensao 1.");
			}
		}
	}
	| CTE_ID '[' E ',' E ']' {
		Tipo *t = buscaVariavel($1.v);
		if (t == NULL)
			erroVND($1.v);
		if ( $3.t.base != tipo('i') || $5.t.base != tipo('i') )
			Erro("Indice de array deve ser um inteiro.");
		if (t->d1 > 0 && t->d2 > 0) {
			$$.t = Tipo( t->base );
			$$.v = geraTemp($$.t);
			string indice = geraTemp( tipo('i') );
			$$.c = $3.c + $5.c +
				indice + " = " + $3.v + " * " + intToStr(t->d2) + ";\n" +
				indice + " = " + indice + " + " + $5.v + ";\n";
			
			if ( t->base == tipo('s') ) {
				$$.c += indice + " = " + indice + " * 256;\n" +
					"strncpy(" + $$.v + ", " + $1.v + " + " + indice + ", 255);\n";
			} else {
				$$.c += $$.v + " = " + $1.v + "[" + indice + "];\n";
			}
		} else {
			if ( (t->d1 > 0 && t->d2 == 0) && t->base == tipo('s') ) {
				$$.t = Tipo( tipo('c') );
				$$.v = geraTemp($$.t);
				string indice = geraTemp( tipo('i') );
				
				$$.c = $3.c + $5.c +
					indice + " = " + $3.v + " * 256;\n" +
					indice + " = " + indice + " + " + $5.v + ";\n" +
					$$.v + " = " + $1.v + "[" + indice + "]";
			} else {
				Erro("Variavel não é um vetor de dimensao 2.");
			}
		}
	}
	| CTE_ID '[' E ',' E ',' E ']' {
		Tipo *t = buscaVariavel($1.v);
		if (t == NULL)
			erroVND($1.v);
		if ( $3.t.base != tipo('i') || $5.t.base != tipo('i') || $7.t.base != tipo('i') )
			Erro("Indice de array deve ser um inteiro.");
		
		if ( (t->d1 > 0 && t->d2 > 0) && t->base == tipo('s') ) {
			$$.t = Tipo( tipo('c') );
			$$.v = geraTemp($$.t);
			string indice = geraTemp( tipo('i') );
			
			$$.c  = indice + " = " + $3.v + " * " + intToStr(t->d2) + ";\n" +
				indice + " = " + indice + " + " + $5.v + ";\n" +
				indice + " = " + indice + " * 256;\n" +
				indice + " = " + indice + " + " + $7.v + ";\n" +
				$$.v + " = " + $1.v + "[" + indice + "];\n";
		} else {
			Erro("Variavel não é um vetor de strings de dimensao 2.");
		}
	}
	| TK_ALEATORIO {
		$$.t = Tipo( tipo('i') );
		$$.v = geraTemp( tipo('i') );
		$$.c = $$.v + " = rand();\n";
	}
	| CTE_ID TK_MENOR_MENOR '{' ARGS '}' { geraCodigoChamaFuncao(&$$, &$1, &$4); }
	| CTE_ID TK_MENOR_MENOR '{' '}' { geraCodigoChamaFuncao(&$$, &$1, &$3); }
	;
	
	AUMENTANIVELVARIAVEL : {
		$$.v = "";
		$$.t = tipo();
		aumentaNivelVariavel();
	}
	;
	
	REDUZNIVELVARIAVEL : {
		$$.v = "";
		$$.t = tipo();
		$$.c = variaveisNaBOXLV();
		reduzNivelVariavel();
	}
	;
	
%%

#include "lex.yy.c"

void yyerror( const char* st )
{
	fprintf(stderr, "%s: Erro na linha %d: %s\n", nomeArquivoEntrada.c_str(), yylineno, st);
	exit(1);
}

void Erro(string s) {
	yyerror(s.c_str());
}

void Erro2(string s) {
	fprintf(stderr, "%s\n", s.c_str());
	exit(1);
}

void erroVND(string nome) {
	Erro("Variavel \"" + nome + "\" nao declarada.");
}

string geraLabel(string nome) {
	return nome + intToStr(++varTemp.nRotulo);
}

string geraTemp(Tipo T) {
	if (T.base == tipo('i'))
		return "T_INT_" + intToStr(++varTemp.nInt);
	else if (T.base == tipo('d'))
		return "T_DOUBLE_" + intToStr(++varTemp.nDouble);
	else if (T.base == tipo('c'))
		return "T_CHAR_" + intToStr(++varTemp.nChar);
	else if (T.base == tipo('s'))
		return "T_STRING_" + intToStr(++varTemp.nString);
	else if (T.base == tipo('b'))
		return "T_BOOL_" + intToStr(++varTemp.nBool);
	else
		yyerror("Impossivel gerar variavel temporaria.");
}

string geraTempStringPointer() {
	return "T_STRING_POINTER_" + intToStr(++varTemp.nStringPointer);
}

string intToStr(int i) {
	char *c = (char*) malloc(sizeof(char)*11);
	sprintf(c, "%d", i);
	return string( c );
}

int strToInt(string s) {
	int *i = (int*) malloc( sizeof(int) );
	sscanf(s.c_str(), "%d", i);
	return *i;
}

void geraCodigoForEach(Atributos *SS, const Atributos *S3, const Atributos *S5, const Atributos *S7, const Atributos *S8) {
	SS->t = Tipo();
	
	Tipo *t = buscaVariavel(S5->v);
	if (!t) erroVND(S5->v);
	
	if ( (S3->t.base != t->base) && !(t->base == tipo('s') && S3->t.base == tipo('c')))
		Erro("Tipos incompativeis entre variavel e vetor/matriz.");
	if ( S3->t.cte || S3->t.d1 > 0)
		Erro("Variavel do foreach deve ter dimensao 0 e nao pode ser constante.");
	if (   t->d1 == 0 && !(t->base == tipo('s') && S3->t.base == tipo('c'))   )
		Erro("Variavel a ser percorrida deve ser um vetor ou uma matriz.");
	
	string i = geraTemp( tipo('i') );
	string e = geraTemp( tipo('b') );
	
	if ( S3->t.base == tipo('s') && t->base == tipo('s') ) { //linha percorre linhas
		string indice = geraTemp( tipo('i') );
		string condicao = geraLabel("L_CONDICAO_");
		string faca = geraLabel("L_FACA_");
		
		if (t->d2 == 0) {	// 1dim
			SS->c = "{\n" +
				S8->c +
				i + " = 0;\n" +
				"goto " + condicao + ";\n" +
				faca + ":;\n" +
				indice + " = " + i + " * 256;\n";
			if (S3->t.ref)	//ref
				SS->c += S3->v + " = " + S5->v + " + " + indice + ";\n";
			else		//nref
				SS->c += "strncpy(" + S3->v + ", " + S5->v + " + " + indice + ", 255);\n";
			SS->c += S7->c +
				i + " = " + i + " + 1;\n" +
				condicao + ":;\n" +
				e + " = " + i + " < " + intToStr(t->d1) + ";\n" +
				"if (" + e + ") goto " + faca + ";\n" +
				"}\n";
		} else {		//2dim
			SS->c = "{\n" +
				S8->c +
				i + " = 0;\n" +
				"goto " + condicao + ";\n" +
				faca + ":;\n" +
				indice + " = " + i + " * 256;\n";
			if (S3->t.ref)	//ref
				SS->c += S3->v + " = " + S5->v + " + " + indice + ";\n";
			else		//nref
				SS->c += "strncpy(" + S3->v + ", " + S5->v + " + " + indice + ", 255);\n";
			SS->c += S7->c +
				i + " = " + i + " + 1;\n" +
				condicao + ":;\n" +
				e + " = " + i + " < " + intToStr(t->d1 * t->d2) + ";\n" +
				"if (" + e + ") goto " + faca + ";\n" +
				"}\n";
		}
	} else if ( S3->t.base == tipo('c') && t->base == tipo('s') ) {	// caracter percorre linhas
		if (t->d1 == 0) {	//0dim
			string condicao = geraLabel("L_CONDICAO_");
			string fim = geraLabel("L_FIM_");
			SS->c = "{\n" +
				S8->c +
				i + " = 0;\n" +
				condicao + ":;\n";
			if (S3->t.ref)	//ref
				SS->c += S3->v + " = " + S5->v + " + " + i + ";\n" +
					e + " = *" + S3->v + " == \'\\0\';\n" +
					"if ( " + e + ") goto " + fim + ";\n";
			else		//nref
				SS->c += S3->v + " = " + S5->v + "[" + i + "];\n" +
					e + " = " + S3->v + " == \'\\0\';\n" +
					"if ( " + e + ") goto " + fim + ";\n";
			SS->c += S7->c +
				i + " = " + i + " + 1;\n" +
				"goto " + condicao + ";\n" +
				fim + ":;\n" +
				"}\n";
		} else if (t->d2 == 0) { //1dim
			string condicao1 = geraLabel("L_CONDICAO1_");
			string condicao2 = geraLabel("L_CONDICAO2_");
			string fim2 = geraLabel("L_FIM2_");
			string faca = geraLabel("L_FACA_");
			string indice = geraTemp( tipo('i') );
			
			SS->c = "{\n" +
				S8->c +
				i + " = 0;\n" +
				"goto " + condicao1 + ";\n" +
				faca + ":;\n" +
				indice + " = " + i + " * 256;\n" +
				condicao2 + ":;\n";
			if (S3->t.ref)	//ref
				SS->c += S3->v + " = " + S5->v + " + " + indice + ";\n" +
					"if ( *" + S3->v + " == \'\\0\') goto " + fim2 + ";\n";
			else		//nref
				SS->c += S3->v + " = " + S5->v + "[" + indice + "];\n" +
					"if ( " + S3->v + " == \'\\0\') goto " + fim2 + ";\n";
			SS->c += S7->c +
				indice + " = " + indice + " + 1;\n" +
				"goto " + condicao2 + ";\n" +
				fim2 + ":;\n" +
				i + " = " + i + " + 1;\n" +
				condicao1 + ":;\n" +
				e + " = " + i + " < " + intToStr(t->d1) + ";\n" +
				"if (" + e + ") goto " + faca + ";\n" +
				"}\n";
		} else { 		//2dim
			string condicao1 = geraLabel("L_CONDICAO1_");
			string condicao2 = geraLabel("L_CONDICAO2_");
			string fim2 = geraLabel("L_FIM2_");
			string faca = geraLabel("L_FACA_");
			string indice = geraTemp( tipo('i') );
			
			SS->c = "{\n" +
				S8->c +
				i + " = 0;\n" +
				"goto " + condicao1 + ";\n" +
				faca + ":;\n" +
				indice + " = " + i + " * 256;\n" +
				condicao2 + ":;\n";
			if (S3->t.ref)	//ref
				SS->c += S3->v + " = " + S5->v + " + " + indice + ";\n" +
					"if ( *" + S3->v + " == \'\\0\') goto " + fim2 + ";\n";
			else		//nref
				SS->c += S3->v + " = " + S5->v + "[" + indice + "];\n" +
					"if ( " + S3->v + " == \'\\0\') goto " + fim2 + ";\n";
			SS->c += S7->c +
				indice + " = " + indice + " + 1;\n" +
				"goto " + condicao2 + ";\n" +
				fim2 + ":;\n" +
				i + " = " + i + " + 1;\n" +
				condicao1 + ":;\n" +
				e + " = " + i + " < " + intToStr(t->d1 * t->d2) + ";\n" +
				"if (" + e + ") goto " + faca + ";\n" +
				"}\n";
		}
	} else {			//outros percorrem outros
		string condicao = geraLabel("L_CONDICAO_");
		string faca = geraLabel("L_FACA_");
		
		if (t->d2 == 0) {	//1dim
			SS->c = "{\n" +
				S8->c +
				i + " = 0;\n" +
				"goto " + condicao + ";\n" +
				faca + ":;\n";
			if (S3->t.ref)	//ref
				SS->c += S3->v + " = " + S5->v + " + " + i + ";\n";
			else		//nref
				SS->c += S3->v + " = " + S5->v + "[" + i + "];\n";
			SS->c += S7->c +
				i + " = " + i + "+ 1;\n" +
				condicao + ":;\n" +
				e + " = " + i + " < " + intToStr(t->d1) + ";\n" +
				"if (" + e + ") goto " + faca + ";\n" +
				"}\n";
		} else {		//2dim
			SS->c = "{\n" +
				S8->c +
				i + " = 0;\n" +
				"goto " + condicao + ";\n" +
				faca + ":;\n";
			if (S3->t.ref)	//ref
				SS->c += S3->v + " = " + S5->v + " + " + i + ";\n";
			else		//nref
				SS->c += S3->v + " = " + S5->v + "[" + i + "];\n";
			SS->c += S7->c +
				i + " = " + i + "+ 1;\n" +
				condicao + ":;\n" +
				e + " = " + i + " < " + intToStr(t->d1 * t->d2) + ";\n" +
				"if (" + e + ") goto " + faca + ";\n" +
				"}\n";
		}
	}
}

void geraCodigoVarForEach(Atributos *SS, const Atributos *S1, const Atributos *S2, const Atributos *S3) {
	*SS = *S3;
	SS->t = S1->t;
	SS->t.ref = S2->t.ref;
	
	insereVariavel( SS->v, new Tipo(SS->t) );
}

void geraCodigoAtrib0D(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	Tipo *t1 = buscaVariavel( S1->v );
	if (!t1)
		erroVND(S1->v);
	testaConstante(&S1->v, t1);
	testaDimensao0(t1);
	testaDimensao0(&S3->t);
	SS->t = resultado("<<", *t1, S3->t);
	if (t1->ref && (t1->base != tipo('s')) )
		SS->v = "(*" + S1->v + ")";
	else
		SS->v = S1->v;
	SS->c = S3->c;
	
	if ( SS->t == tipo('s') ) {
		string v3;
		
		trataConversaoCharIntDoubleBoolToString(&v3, SS, S3);
		
		if (S3->t.ref)
			SS->c += "strncpy(" + SS->v + ", &" + v3 + ", 255);\n";
		else
			SS->c += "strncpy(" + SS->v + ", " + v3 + ", 255);\n";
	} else if ( t1->base == tipo('i') && S3->t.base == tipo('d') ){
		string temp = geraTemp( tipo('i') );
		
		SS->c += temp + " = (int) " + S3->v + ";\n" +
			SS->v + " = " + temp + ";\n";
	} else {
		SS->c += SS->v + " = " + S3->v + ";\n";
	}
}

void testaConstante(const string *nome, const Tipo *T) {
	if (T->cte == true)
		Erro("Impossivel atribuir valor a \"" + *nome + "\", variavel do tipo constante");
}

void testaDimensao0(const Tipo *t1) {
	if (t1->d1 > 0 || t1->d2 > 0)
		Erro("Nao é possivel realizar esta operacao com uma matriz de elementos.");
}

void geraCodigoAtrib1D(Atributos *SS, const Atributos *S1, const Atributos *S3, const Atributos *S6) {
	Tipo *t1 = buscaVariavel( S1->v );
	if (!t1)
		erroVND(S1->v);
	testaConstante(&S1->v, t1);
	testaDimensao0(&S6->t);
	if ( S3->t.base != tipo('i')  )
		Erro("Indice de array deve ser um inteiro.");
	SS->v = S1->v;
	SS->c = S3->c + S6->c;
	
	if (t1->d1 > 0 && t1->d2 == 0) {
		SS->t = resultado("<<", *t1, S6->t);
		
		if ( SS->t == tipo('s') ) {
			string v6;
			string indice = geraTemp( tipo('i') );
			
			trataConversaoCharIntDoubleBoolToString(&v6, SS, S6);
			
			SS->c += indice + " = " + S3->v + " * 256;\n" + 
				"strncpy(" + S1->v + "+" + indice + ", " + v6 + ", 255);\n";
		} else if ( t1->base == tipo('i') && S6->t.base == tipo('d') ){
			string temp = geraTemp( tipo('i') );
		
			SS->c += temp + " = (int) " + S6->v + ";\n" +
				SS->v + "[" + S3->v + "] = " + temp + ";\n";
		} else {
			SS->c += SS->v + "[" + S3->v + "] = " + S6->v + ";\n";
		}
	} else {
		if ((t1->d1 == 0 && t1->d2 == 0) && t1->base == tipo('s') ) {
			SS->t = resultado("<<", Tipo( tipo('c') ), S6->t);
			SS->c += SS->v + "[" + S3->v + "] = " + S6->v + ";\n";
		} else {
			Erro("Variavel não é um vetor de dimensao 1.");
		}
	}
}

void geraCodigoAtrib2D(Atributos *SS, const Atributos *S1, const Atributos *S3, const Atributos *S5, const Atributos *S8) {
	Tipo *t1 = buscaVariavel( S1->v );
	if (!t1)
		erroVND(S1->v);
	testaConstante(&S1->v, t1);
	testaDimensao0(&S8->t);
	if ( S3->t.base != tipo('i')  || S5->t.base != tipo('i') )
		Erro("Indice de array deve ser um inteiro.");
	SS->v = S1->v;
	SS->c = S3->c + S5->c + S8->c;
	string indice = geraTemp( tipo('i') );
	
	if (t1->d1 > 0 && t1->d2 > 0) {
		SS->t = resultado("<<", *t1, S8->t);
	
		SS->c += indice + " = " + S3->v + " * " + intToStr( t1->d2 ) + ";\n" +
			indice + " = " + indice + " + " + S5->v + ";\n";
	
		if ( SS->t == tipo('s') ) {
			string v8;
			
			trataConversaoCharIntDoubleBoolToString(&v8, SS, S8);
			
			SS->c += indice + " = " + indice + " * 256;\n" +
				"strncpy(" + SS->v + " + " + indice + ", " + v8 + ", 255);\n";
		} else if ( t1->base == tipo('i') && S8->t.base == tipo('d') ){
			string temp = geraTemp( tipo('i') );
			
			SS->c += temp + " = (int) " + S8->v + ";\n" +
				SS->v + "[" + indice + "] = " + temp + ";\n";
		} else {
			SS->c += SS->v + "[" + indice + "] = " + S8->v + ";\n";
		}
	} else {
		if ( (t1->d1 > 0 && t1->d2 == 0) && t1->base == tipo('s') ) {
			SS->t = resultado("<<", Tipo( tipo('c') ), S8->t);
			SS->c += indice + " = " + S3->v + " * 256;\n" +
				indice + " = " + indice + " + " + S5->v + ";\n" +
				SS->v + "[" + indice + "] = " + S8->v + ";\n";
		} else {
			Erro("Variavel não é um vetor de dimensao 2.");
		}
	}
}

void geraCodigoAtrib3D(Atributos *SS, const Atributos *S1, const Atributos *S3, const Atributos *S5, const Atributos *S7, const Atributos *S10) {
	Tipo *t1 = buscaVariavel( S1->v );
	testaConstante(&S1->v, t1);
	testaDimensao0(&S10->t);
	if ( S3->t.base != tipo('i')  || S5->t.base != tipo('i') || S7->t.base != tipo('i') )
		Erro("Indice de array deve ser um inteiro.");
	SS->v = S1->v;
	SS->c = S3->c + S5->c + S7->c + S10->c;
	string indice = geraTemp( tipo('i') );
	
	if ( (t1->d1 > 0 && t1->d2 > 0) && t1->base == tipo('s') ) {
		SS->t = resultado("<<", Tipo( tipo('c') ), S10->t);
		
		SS->c += indice + " = " + S3->v + " * " + intToStr(t1->d2) + ";\n" +
			indice + " = " + indice + " + " + S5->v + ";\n" +
			indice + " = " + indice + " * 256;\n" +
			indice + " = " + indice + " + " + S7->v + ";\n" +
			SS->v + "[" + indice + "] = " + S10->v + ";\n";
	} else {
		Erro("Variavel não é um vetor de strings de dimensao 2.");
	}
}

void aumentaNivelVariavel() {
	BOXLV *novo = new BOXLV();
	novo->ant = top;
	top = novo;
}

void reduzNivelVariavel() {
	BOXLV *old = top;
	top = top->ant;
	delete(old);
}
string variaveisNaBOXLV() {
	string s = "";
	map<string, Tipo *>::const_iterator it;
	for (it = top->LV.begin(); it != top->LV.end(); ++it) {
		if (it->second->cabecalho == false) {
			s += geraCodigoTipo(it->second);
			if (it->second->ref) {
				s += " *" + it->first;
			} else {
					s += " " + it->first;
				if ( it->second->d1 > 0 ) {
					if ( it->second->d2 > 0 ) {
						if (it->second->base == tipo('s')) {
							s += "[" + intToStr(it->second->d1 * (it->second->d2) * 256) + "]";
						} else {
							s += "[" + intToStr(it->second->d1 * (it->second->d2)) + "]";
						}
					} else {
						if (it->second->base == tipo('s')) {
							s += "[" + intToStr(it->second->d1 * 256) + "]";
						} else {
							s += "[" + intToStr(it->second->d1) + "]";
						}
					}
				} else {
					if (it->second->base == tipo('s'))
						s += "[256]";
				}
			}
			s += ";\n";
		}
	}
	return s;
}

string boolToStr(bool b) {
	if (b) 
		return "true";
	else
		return "false";
}

void insereVariavel(string nome, Tipo *T) {
	if (buscaVariavel(nome) == NULL) {
		top->LV[nome] = T;
		//cout << "Inserindo variavel: " + nome + ",d1=" + intToStr(T->d1) + ",d2=" + intToStr(T->d2) + ",cte=" + boolToStr(T->cte) + ",ref=" + boolToStr(T->ref) + "\n";
	} else {
		Erro("Variável já declarada: " + nome);
	}
}

Tipo *buscaVariavel(string nome) {
	BOXLV *atual = top;
	
	while(atual != NULL) {
		if (atual->LV.find(nome) != atual->LV.end())
			return atual->LV[nome];
		atual = atual->ant;
	}
	
	return NULL;
}

Funcao *buscaFuncao(string nome) {
	if (listaFuncoes.find(nome) != listaFuncoes.end())
		return listaFuncoes[nome];
	return NULL;
}

void insereParam(string nome, Tipo *T){
	T->cabecalho = true;
	insereVariavel(nome, T);
	params.push_back(*T);
}

void insereFuncao(string nome, Tipo retorno, bool corpo, bool cabecalho) {
	if ( listaFuncoes.find(nome) == listaFuncoes.end() ) {
		listaFuncoes[nome] = new Funcao(retorno);
		params.clear();
	} else {
		if (corpo) {
			if (listaFuncoes[nome]->corpo) {
				Erro("Corpo da funcao \"" + nome + "\" jah definido");
			} else {
				listaFuncoes[nome]->corpo = true;
			}
		} else if (cabecalho) {
			if (listaFuncoes[nome]->cabecalho) {
				Erro("Cabecalho da funcao \"" + nome + "\" jah definido");
			} else {
				listaFuncoes[nome]->cabecalho = true;
			}
		}
	}
}

Tipo verificaArray0D(string nome) {
	Tipo *aux = buscaVariavel(nome);
	if ( aux == NULL )
		Erro("Variavel nao declarada: " + nome);
	if ( aux->d1 > 0 || aux->d2 > 0 )
		Erro("Variavel eh um vetor ou uma matriz");
	return *aux;
}

Tipo verificaArray1D(string nome) {
	Tipo *aux = buscaVariavel(nome);
	if ( aux == NULL )
		Erro("Variavel nao declarada: " + nome);
	if ( aux->d1 == 0 || aux->d2 > 0 )
		Erro("Variavel nao eh um vetor ou nao eh um vetor de 1 dimensao.");
	return *aux;
}

Tipo verificaArray2D(string nome) {
	Tipo *aux = buscaVariavel(nome);
	if ( aux == NULL )
		Erro("Variavel nao declarada: " + nome);
	if ( aux->d1 == 0 || aux->d2 == 0 )
		Erro("Variavel nao eh um vetor ou nao eh um vetor de 2 dimensoes.");
	return *aux;
}

void geraCodigoChamaFuncao(Atributos *SS, const Atributos *S1, const Atributos *S4) {
	SS->t = verificaFuncao(S1->v, S4->args);
	SS->c = S4->c;
	
	if (SS->t.base == tipo('v')) {
		SS->c += S1->v + "(" + geraParamsFinais(S1, S4) + ");\n";
	} else {
		SS->v = geraTemp( SS->t );
		if ( SS->t.base == tipo('s') ) {
			string temp = geraTempStringPointer();
			SS->c += temp + " = " + S1->v + "(" + geraParamsFinais(S1, S4) + ");\n" +
				"strncpy(" + SS->v + ", " + temp + ", 255);\n" +
				"free(" + temp + ");\n";
		} else {
			SS->c += SS->v + " = " + S1->v + "(" + geraParamsFinais(S1, S4) + ");\n";
		}
	}
}

string geraParamsFinais(const Atributos *S1, const Atributos *S4) {
	string s = "";
	
	vector<Tipo> f = listaFuncoes[S1->v]->param;
	vector<Tipo>::const_iterator itt;
	vector<string>::const_iterator itv;
	
	for ( (itt = f.begin(),itv = S4->vars.begin()) ; ( itt != f.end() ) ; (++itt, ++itv) ) {
		if (itt->ref && itt->d1 ==0) {
			if (itt->base == tipo('s')) {
				if (itt == f.begin())
					s += "*&" + *itv;
				else
					s += ", *&" + *itv;
			} else {
				if (itt == f.begin())
					s += "&" + *itv;
				else
					s += ", &" + *itv;
			}
		} else {
			if (itt == f.begin()) {
				s += *itv;
			} else {
				s += ", " + *itv;
			}
		}
	}
	
	return s;
}

Tipo verificaFuncao(string nome, vector<Tipo> args) {
	if (listaFuncoes.find(nome) != listaFuncoes.end()) {
		testaParametrosCompativeis(nome, args);
		return listaFuncoes[nome]->retorno;
	} else {
		Erro("Funcao nao declarada: " + nome);
	}
}

void testaParametrosCompativeis(string nome, vector<Tipo> c) {
	vector<Tipo> f = listaFuncoes[nome]->param;
	vector<Tipo>::const_iterator itf, itc;
	Tipo a, b;
	
	for ( (itf = f.begin(), itc = c.begin()); ( itf != f.end() ) && ( (a = *itf) == (b = *itc) ); ( ++itf, ++itc) );
	
	if ( (itf != f.end()) || (itc != c.end()) ) {
		string esperado, encontrado;
		
		for (itf = f.begin() ; itf != f.end() ; ++itf) {
			if (itf == f.begin()) {
				esperado = geraCodigoTipoTransiberian(&*itf);
			} else {
				esperado += ", " + geraCodigoTipoTransiberian(&*itf);
			}
		}
			
		for (itc = c.begin() ; itc != c.end() ; ++itc) {
			if (itc == c.begin()) {
				encontrado = geraCodigoTipoTransiberian(&*itc);
			} else {
				encontrado += ", " + geraCodigoTipoTransiberian(&*itc);
			}
		}
		
		Erro("Parametros incorretos, funcao \"" + nome + "\" espera (" + esperado + ") mas foi encontrado (" + encontrado + ")");
	}
}

void geraCodigoCabecalho(Atributos *SS, const Atributos *S3, const Atributos *S6, const Atributos *S8) {
	insereFuncao(S6->v, S8->t, false, false);
	tipoRetorno = S8->t.base;
	retornou = false;
	
	if ( strncmp(S6->v.c_str(), "_inicio", 255) == 0 ) {
		SS->v = "main";
		naMain = true;
	} else {
		SS->v = S6->v;
		naMain = false;
	}
	SS->t = S8->t;
	
	if (strncmp(S3->c.c_str(), "", 2) == 0) {
		if (naMain) {
			SS->c = "int " + SS->v  + "()";
		} else {
			SS->c = geraCodigoTipoRetorno(&S8->t) + " " + SS->v  + "()";
		}
		
	} else {
		if (naMain) {
			SS->c = "int " + SS->v  + "(" + S3->c + ")";
		} else {
			SS->c = geraCodigoTipoRetorno(&S8->t) + " " + SS->v  + "(" + S3->c + ")";
		}
		
	}
}

string geraCodigoTipoRetorno(const Tipo *T) {
	string s = "";
	if (T->cte)
		s += "const ";
	
	if (T->base == tipo('i'))      return s + "int";
	else if (T->base == tipo('c')) return s + "char";
	else if (T->base == tipo('s')) return s + "char *";
	else if (T->base == tipo('f')) return s + "float";
	else if (T->base == tipo('b')) return s + "int";
	else if (T->base == tipo('d')) return s + "double";
	else if (T->base == tipo('v')) return s + "void";
	else                           return "";
}

string geraCodigoTipo(const Tipo *T) {
	string s = "";
	
	if (T->cte)
		s += "const ";
	
	if (T->base == tipo('i'))      return s + "int";
	else if (T->base == tipo('c')) return s + "char";
	else if (T->base == tipo('s')) return s + "char";
	else if (T->base == tipo('f')) return s + "float";
	else if (T->base == tipo('b')) return s + "int";
	else if (T->base == tipo('d')) return s + "double";
	else if (T->base == tipo('v')) return s + "void";
	else                           return "";
}

string geraCodigoTipoTransiberian(const Tipo *T) {
	string s;
	
	if (T->cte) s = "const " + s;
	
	if (T->base == tipo('i'))      s += "inteiro";
	else if (T->base == tipo('c')) s += "caractere";
	else if (T->base == tipo('s')) s += "linha";
	else if (T->base == tipo('f')) s += "flutuante";
	else if (T->base == tipo('b')) s += "booleano";
	else if (T->base == tipo('d')) s += "duplo";
	else if (T->base == tipo('v')) s += "vazio";
	else                           s += "";
	
	if (T->d1 > 0 && T->d2 == 0) {
		s += "[" + intToStr(T->d1) + "]";
	} else if (T->d1 > 0 && T->d2 > 0) {
		s += "[" + intToStr(T->d1) + ", " + intToStr(T->d2) + "]";
	}
	
	return s;
}

void geraCodigoOprGenerico(string opr, Atributos *SS, const Atributos *S1, const Atributos *S3) {
	SS->t = resultado(opr, S1->t, S3->t);
	SS->v = geraTemp(SS->t);
	SS->c = S1->c + S3->c +
		SS->v + " = " + S1->v + opr + S3->v + ";\n";
}

void geraCodigoAdicao(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	SS->t = resultado("+", S1->t, S3->t);
	
	if (SS->t.base == tipo('s')) {
		SS->v = geraTemp(SS->t);
		SS->c = S1->c + S3->c;
		string v1, v3;
		
		trataConversaoCharIntDoubleBoolToString(&v1, SS, S1);
		trataConversaoCharIntDoubleBoolToString(&v3, SS, S3);
		if (S1->t.ref)
			SS->c += "strncpy(" + SS->v + ", &" + v1 + ", 255);\n";
		else
			SS->c += "strncpy(" + SS->v + ", " + v1 + ", 255);\n";
		if (S3->t.ref)
			SS->c += "strncat(" + SS->v + ", &" + v3 + ", 255);\n";
		else
			SS->c += "strncat(" + SS->v + ", " + v3 + ", 255);\n";
	} else {
		geraCodigoOprGenerico("+", SS, S1, S3);
	}
}

void geraCodigoSubtracao(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprGenerico("-", SS, S1, S3);
}

void geraCodigoMultiplicacao(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprGenerico("*", SS, S1, S3);
}

void geraCodigoDivisao(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprGenerico("/", SS, S1, S3);
}

void geraCodigoExponencial(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	SS->t = resultado("^", S1->t, S3->t);
	SS->v = geraTemp(SS->t);
	SS->c = S1->c + S3->c +
		SS->v + " = " + "pow(" + S1->v + ", " + S3->v + ");\n";
}

void geraCodigoModulo(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprGenerico("%", SS, S1, S3);
}

void geraCodigoE(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprGenerico("&&", SS, S1, S3);
}

void geraCodigoOu(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprGenerico("||", SS, S1, S3);
}

void geraCodigoXou(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	SS->t = resultado("^^", S1->t, S3->t);
	SS->v = geraTemp(SS->t);
	SS->c = S1->c + S3->c +
		SS->v + " = (!" + S1->v + ") ^ (!" + S3->v + ");\n";
}

void geraCodigoMaior(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprRelacional(">", SS, S1, S3);
}

void geraCodigoMenor(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprRelacional("<", SS, S1, S3);
}

void geraCodigoMaiorIgual(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprRelacional(">=", SS, S1, S3);
}

void geraCodigoMenorIgual(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprRelacional("<=", SS, S1, S3);
}

void geraCodigoOprRelacional(string opr, Atributos *SS, const Atributos *S1, const Atributos *S3) {
	if (S1->t.base == tipo('s') || S3->t.base == tipo('s')) {
		SS->t = resultado(opr, S1->t, S3->t);
		SS->v = geraTemp(SS->t);
		SS->c = S1->c + S3->c;
		string v1, v3;
		
		trataConversaoCharIntDoubleBoolToString(&v1, SS, S1);
		trataConversaoCharIntDoubleBoolToString(&v3, SS, S1);
		
		SS->c += SS->v + " = !!(strncmp( " + v1 + ", " + v3 + ", 255) " + opr + "0);\n";
	} else {
		geraCodigoOprGenerico(opr, SS, S1, S3);
	}
}

void geraCodigoIgual(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprRelacional("==", SS, S1, S3);
}

void geraCodigoNao(Atributos *SS, const Atributos *S2) {
	SS->t = resultado("!", S2->t, tipo());
	SS->v = geraTemp(SS->t);
	SS->c = S2->c +
		SS->v + " = !" + S2->v + ";\n";
}

void geraCodigoMenosUnario(Atributos *SS, const Atributos *S2) {
	SS->t = resultado("-", S2->t, tipo());
	SS->v = geraTemp(SS->t);
	SS->c = S2->c +
		SS->v + " = -" + S2->v + ";\n";
}

void geraCodigoMaisUnario(Atributos *SS, const Atributos *S2) {
	SS->t = resultado("+", S2->t, tipo());
	SS->v = geraTemp(SS->t);
	SS->c = S2->c +
		SS->v + " = +" + S2->v + ";\n";
}

void geraCodigoNaoIgual(Atributos *SS, const Atributos *S1, const Atributos *S3) {
	geraCodigoOprRelacional("!=", SS, S1, S3);
}

void trataConversaoCharIntDoubleBoolToString(string *v, Atributos *SS, const Atributos *Sn) {
	if (Sn->t.base == tipo('c')) {
		*v = geraTemp(tipo('s'));
		SS->c += *v + "[0] = " + Sn->v + ";\n" +
			*v + "[1] = \'\\0\';\n";
	} else if (Sn->t.base == tipo('i')) {
		*v = geraTemp(tipo('s'));
		SS->c += "sprintf(" + *v + ", \"%d\", " + Sn->v + ");\n";
	} else if (Sn->t.base == tipo('d')) {
		*v = geraTemp(tipo('s'));
		SS->c += "sprintf(" + *v + ", \"%lf\", " + Sn->v + ");\n";
	} else if (Sn->t.base == tipo('b')) {
		*v = geraTemp(tipo('s'));
		SS->c += "if (" + Sn->v + ")\n" +
			"strncpy(" + *v + ", \"verdadeiro\", 255);\n" + 
			"else\n" +
			"strncpy(" + *v + ", \"falso\", 255);\n";
	} else *v = Sn->v;
}

string declaraTemporarias() {
	string s = "";
	int i;
	
	for ( i = 1 ; i <= varTemp.nInt ; i++ )
		s += "int T_INT_" + intToStr(i) + ";\n";
	
	for ( i = 1 ; i <= varTemp.nDouble ; i++ )
		s += "double T_DOUBLE_" + intToStr(i) + ";\n";
	
	for ( i = 1 ; i <= varTemp.nChar ; i++ )
		s += "char T_CHAR_" + intToStr(i) + ";\n";
	
	for ( i = 1 ; i <= varTemp.nString ; i++ )
		s += "char T_STRING_" + intToStr(i) + "[256];\n";
	
	for ( i = 1 ; i <= varTemp.nBool ; i++ )
		s += "int T_BOOL_" + intToStr(i) + ";\n";
	
	for ( i = 1 ; i <= varTemp.nStringPointer ; i++ )
		s += "char *T_STRING_POINTER_" + intToStr(i) + ";\n";
	
	varTemp.nInt = varTemp.nDouble = varTemp.nChar = varTemp.nString = varTemp.nBool = varTemp.nStringPointer = 0;
	
	return s;
}

tipo resultado(string operador, Tipo op1, Tipo op2) {
	if ( tabResOper.find(operador+op1.getBase()+op2.getBase()) != tabResOper.end() )
		return tabResOper[operador+op1.getBase()+op2.getBase()];
	else
		Erro("Operacao invalida: (" + geraCodigoTipoTransiberian( &op1 ) + ") " + operador + " (" +
			geraCodigoTipoTransiberian( &op2 )  + ")");
}

void criaTabelaResultado() {
	tabResOper["+ii"] = tipo('i');
	tabResOper["+id"] = tipo('d');
	tabResOper["+di"] = tipo('d');
	tabResOper["+dd"] = tipo('d');
	tabResOper["+si"] = tipo('s');
	tabResOper["+is"] = tipo('s');
	tabResOper["+ds"] = tipo('s');
	tabResOper["+sd"] = tipo('s');
	tabResOper["+ss"] = tipo('s');
	tabResOper["+sc"] = tipo('s');
	tabResOper["+cs"] = tipo('s');
	tabResOper["+sb"] = tipo('s');
	tabResOper["+bs"] = tipo('s');
	tabResOper["+cc"] = tipo('c');
	tabResOper["+ic"] = tipo('c');
	tabResOper["+ci"] = tipo('c');
	
	tabResOper["-ii"] = tipo('i');
	tabResOper["-id"] = tipo('d');
	tabResOper["-di"] = tipo('d');
	tabResOper["-dd"] = tipo('d');
	tabResOper["-ic"] = tipo('c');
	tabResOper["-ci"] = tipo('c');
	tabResOper["-cc"] = tipo('c');
	
	tabResOper["*ii"] = tipo('i');
	tabResOper["*id"] = tipo('d');
	tabResOper["*di"] = tipo('d');
	tabResOper["*dd"] = tipo('d');
	
	tabResOper["/ii"] = tipo('i');
	tabResOper["/id"] = tipo('d');
	tabResOper["/di"] = tipo('d');
	tabResOper["/dd"] = tipo('d');
	
	tabResOper["^ii"] = tipo('i');
	tabResOper["^id"] = tipo('d');
	tabResOper["^di"] = tipo('d');
	tabResOper["^dd"] = tipo('d');
	
	tabResOper["%ii"] = tipo('i');
	
	tabResOper[">ii"] = tipo('b');
	tabResOper[">id"] = tipo('b');
	tabResOper[">di"] = tipo('b');
	tabResOper[">dd"] = tipo('b');
	tabResOper[">ic"] = tipo('b');
	tabResOper[">ci"] = tipo('b');
	tabResOper[">ss"] = tipo('b');
	tabResOper[">sc"] = tipo('b');
	tabResOper[">cs"] = tipo('b');
	tabResOper[">cc"] = tipo('b');
	
	tabResOper["<ii"] = tipo('b');
	tabResOper["<id"] = tipo('b');
	tabResOper["<di"] = tipo('b');
	tabResOper["<dd"] = tipo('b');
	tabResOper["<ic"] = tipo('b');
	tabResOper["<ci"] = tipo('b');
	tabResOper["<ss"] = tipo('b');
	tabResOper["<sc"] = tipo('b');
	tabResOper["<cs"] = tipo('b');
	tabResOper["<cc"] = tipo('b');
	
	tabResOper[">=ii"] = tipo('b');
	tabResOper[">=id"] = tipo('b');
	tabResOper[">=di"] = tipo('b');
	tabResOper[">=dd"] = tipo('b');
	tabResOper[">=ic"] = tipo('b');
	tabResOper[">=ci"] = tipo('b');
	tabResOper[">=ss"] = tipo('b');
	tabResOper[">=sc"] = tipo('b');
	tabResOper[">=cs"] = tipo('b');
	tabResOper[">=cc"] = tipo('b');
	
	tabResOper["<=ii"] = tipo('b');
	tabResOper["<=id"] = tipo('b');
	tabResOper["<=di"] = tipo('b');
	tabResOper["<=dd"] = tipo('b');
	tabResOper["<=ic"] = tipo('b');
	tabResOper["<=ci"] = tipo('b');
	tabResOper["<=ss"] = tipo('b');
	tabResOper["<=sc"] = tipo('b');
	tabResOper["<=cs"] = tipo('b');
	tabResOper["<=cc"] = tipo('b');
	
	tabResOper["==ii"] = tipo('b');
	tabResOper["==id"] = tipo('b');
	tabResOper["==di"] = tipo('b');
	tabResOper["==dd"] = tipo('b');
	tabResOper["==ic"] = tipo('b');
	tabResOper["==ci"] = tipo('b');
	tabResOper["==ss"] = tipo('b');
	tabResOper["==sc"] = tipo('b');
	tabResOper["==cs"] = tipo('b');
	tabResOper["==cc"] = tipo('b');
	tabResOper["==bb"] = tipo('b');
	
	tabResOper["!=ii"] = tipo('b');
	tabResOper["!=id"] = tipo('b');
	tabResOper["!=di"] = tipo('b');
	tabResOper["!=dd"] = tipo('b');
	tabResOper["!=ic"] = tipo('b');
	tabResOper["!=ci"] = tipo('b');
	tabResOper["!=ss"] = tipo('b');
	tabResOper["!=sc"] = tipo('b');
	tabResOper["!=cs"] = tipo('b');
	tabResOper["!=cc"] = tipo('b');
	tabResOper["!=bb"] = tipo('b');
	
	tabResOper["&&bb"] = tipo('b');
	
	tabResOper["||bb"] = tipo('b');
	
	tabResOper["^^bb"] = tipo('b');
	
	tabResOper["!b"] = tipo('b');
	
	tabResOper["-i"] = tipo('i');
	tabResOper["-d"] = tipo('d');
	
	tabResOper["+i"] = tipo('i');
	tabResOper["+d"] = tipo('d');
	
	tabResOper["<<ii"] = tipo('i');
	tabResOper["<<id"] = tipo('i');
	tabResOper["<<di"] = tipo('d');
	tabResOper["<<dd"] = tipo('d');
	tabResOper["<<si"] = tipo('s');
	tabResOper["<<sd"] = tipo('s');
	tabResOper["<<ss"] = tipo('s');
	tabResOper["<<sc"] = tipo('s');
	tabResOper["<<cc"] = tipo('c');
	tabResOper["<<bb"] = tipo('b');
}

void escreveTela(string s) {
	cout << " ---> Saida do compilador para \"" << nomeArquivoEntrada << "\":" << endl << endl;
	cout << s;
}

void escreveArquivo(string s) {	
	fprintf(saida, "%s", s.c_str());
	cout << endl << "---> Arquivo \"" << nomeArquivoSaida << "\" gerado com sucesso." << endl << endl;
}

int main( int argc, char* argv[] )
{
	criaTabelaResultado();
	aumentaNivelVariavel();
	
	int i;
	bool sobrescrever = false;
	bool arquivoEntradaEspecificado = false;
	yydebug = 0;
	
	if (argc == 1) 
		mostrarSintaxe();
	
	for ( i = 1 ; i < argc ; i++ ) {
		if (argv[i][0] == '-') {
			switch(argv[i][1]) {
				case 't' : {
					saidaTela = true;
				} break;
				case 'o' : {
					i++;
					if (i>=argc) {
						Erro2("Esperado nome do arquivo de saida após \"-s\".");
					} else {
						saidaArquivo = true;
						nomeArquivoSaida = argv[i];
					}
				} break;
				case 's' : {
					sobrescrever = true;
				} break;
				case 'g' : {
					yydebug = 1;
				} break;
			}
		} else {
			arquivoEntradaEspecificado = true;
			nomeArquivoEntrada = argv[i];
		}
	}
	
	if (arquivoEntradaEspecificado) {
		entrada = fopen(nomeArquivoEntrada.c_str(), "r");
		if (!entrada) {
			Erro2("Erro ao abrir o arquivo de entrada.");
		}
	} else {
		Erro2("Arquivo fonte nao especificado.");
	}
	
	if (saidaArquivo) {
		saida = fopen(nomeArquivoSaida.c_str(), "r");
		if (saida) {
			char op;
			if (!sobrescrever) {
				cout << "Arquivo ja existe, sobrescrever? [s/n] ";
				cin >> op;
			}
			if (op == 's' || op == 'S' || sobrescrever) {
				saida = fopen(nomeArquivoSaida.c_str(), "w");
				if (!saida)
					Erro2("Nao foi possivel abrir o arquivo para escrita.");
			} else {
				exit(0);
			}
		} else {
			saida = fopen(nomeArquivoSaida.c_str(), "w");
			if (!saida)
				Erro2("Nao foi possivel abrir o arquivo para escrita.");
		}
	}
	
	yy_switch_to_buffer( yy_create_buffer(entrada, YY_BUF_SIZE) );
	yyparse();
}

void mostrarSintaxe() {
	cout << "Nome: transiberian" << endl << endl;
	cout << "Sintaxe: transiberian [ARQUIVO DE ENTRADA] [OPCOES]" << endl << endl;
	cout << "[ARQUIVO DE ENTRADA]\n		Nome do arquivo a ser compilado.\n\n";
	cout << "[OPCOES]\n";
	cout << "		-t 		: Mostra a saida da compilação na saida padrão.\n";
	cout << "		-o [ARQUIVO]	: Salva o codigo gerado no arquivo especificado.\n";
	cout << "		-s		: Usando em conjunto com -o, salva o arquivo sem comfirmacao para sobrescrever.\n";
	cout << "		-g		: Modo de depuracao do compilador.\n";
	exit(0);
}

