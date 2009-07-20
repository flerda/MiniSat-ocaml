MINISATDIR=../MiniSat/src

all: lib solver

lib: MiniSAT.cma MiniSAT.cmi

solver: solver.cmo MiniSAT.cma
	ocamlc -o solver MiniSAT.cma solver.cmo
	
MiniSAT.cma: Solver.o MiniSATWrap.o MiniSAT.cmo
	ocamlc -a -custom Solver.o MiniSATWrap.o MiniSAT.cmo -o MiniSAT.cma -cclib -lstdc++

Solver.o: $(MINISATDIR)/Solver.C
	g++ -c -I $(MINISATDIR) $(MINISATDIR)/Solver.C

MiniSATWrap.o: MiniSATWrap.C
	g++ -c -I /usr/lib/ocaml -I $(MINISATDIR) MiniSATWrap.C

MiniSAT.cmo: MiniSAT.ml MiniSAT.cmi
	ocamlc -c MiniSAT.ml

MiniSAT.cmi: MiniSAT.mli
	ocamlc -c MiniSAT.mli

solver.cmo: solver.ml MiniSAT.cmi
	ocamlc -c solver.ml

clean:
	rm -f *.o *.cmo *.cma *.cmi *~ solver
