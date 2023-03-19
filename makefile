all: transiberian Executaveis

transiberian: lex.yy.c y.tab.c
	g++ -o transiberian y.tab.c -lfl -g

lex.yy.c: comp.lex
	lex comp.lex

y.tab.c: comp.y
	yacc -d comp.y --verbose --debug

entrada: transiberian entrada.czar
	./transiberian entrada.czar -o entrada.cpp -s -t

OrdenaVetor: transiberian ordenaVetor.czar
	./transiberian ordenaVetor.czar -o ordenaVetor.cpp -s -t

LetrasMaiusculas: transiberian letrasMaiusculas.czar
	./transiberian letrasMaiusculas.czar -o letrasMaiusculas.cpp -s -t

Fatorial : transiberian fatorial.czar
	./transiberian fatorial.czar -o fatorial.cpp -s -t

Fibonacci : transiberian fibonacci.czar
	./transiberian fibonacci.czar -o fibonacci.cpp -s -t

Executaveis: OrdenaVetor LetrasMaiusculas Fatorial  Fibonacci entrada
	g++ ordenaVetor.cpp -o ordenaVetor -Wall
	g++ letrasMaiusculas.cpp -o letrasMaiusculas -Wall
	g++ fatorial.cpp -o fatorial -Wall
	g++ entrada.cpp -o entrada -Wall
	g++ fibonacci.cpp -o fibonacci -Wall -g
clean:
	rm lex.yy.c
	rm y.tab.h
	rm y.tab.c
	rm y.output
	rm transiberian
	rm fatorial
	rm letrasMaiusculas
	rm ordenaVetor
	rm fibonacci
	rm entrada
	rm *.cpp
	rm *~
	
