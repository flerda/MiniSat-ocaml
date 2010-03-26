
NAME = minisat
VERSION = 0.3

LIBS = _build/minisat.cma
LIBS_OPT = _build/minisat.cmxa
PROGS = _build/solver.byte
PROGS_OPT = _build/solver.native
RESULTS = $(LIBS) $(PROGS)
RESULTS_OPT = $(LIBS_OPT) $(PROGS_OPT)
SOURCES = $(wildcard *.ml *.mli)

OCAMLBUILD = ocamlbuild
#OBFLAGS = -classic-display
OBFLAGS =
OCAMLFIND = ocamlfind

DESTDIR =
LIBDIR = $(DESTDIR)/$(shell ocamlc -where)
BINDIR = $(DESTDIR)/usr/bin
ifeq ($(DESTDIR),)
INSTALL = $(OCAMLFIND) install
UNINSTALL = $(OCAMLFIND) remove
else
INSTALL = $(OCAMLFIND) install -destdir $(LIBDIR)
UNINSTALL = $(OCAMLFIND) remove -destdir $(LIBDIR)
endif

DIST_DIR = $(NAME)-$(VERSION)
DIST_TARBALL = $(DIST_DIR).tar.gz
DEB_TARBALL = $(subst -,_,$(DIST_DIR).orig.tar.gz)

all: $(RESULTS)
opt: $(RESULTS_OPT)
$(RESULTS): $(SOURCES)
$(RESULTS_OPT): $(SOURCES)

clean:
	$(OCAMLBUILD) $(OBFLAGS) -clean

_build/%:
	$(OCAMLBUILD) $(OBFLAGS) $*
	@touch $@

docs:
	if [ ! -d doc ]; then mkdir doc; fi
	ocamldoc $(OCFLAGS) -html -d doc minisat.mli

INSTALL_STUFF = META
INSTALL_STUFF += $(wildcard _build/*minisat*.cma _build/minisat.cmxa _build/*minisat*.a)
INSTALL_STUFF += $(wildcard _build/*minisat*.cmi) $(wildcard *.mli)
INSTALL_STUFF += $(wildcard _build/*minisat*.cmx _build/dllminisat_stubs.so)

# -ldconf ignore _build/dllminisat_stubs.so

install:
	test -d $(LIBDIR) || mkdir -p $(LIBDIR)
	$(INSTALL) -ldconf ignore -patch-version $(VERSION) $(NAME) $(INSTALL_STUFF)

uninstall:
	$(UNINSTALL) $(NAME)
