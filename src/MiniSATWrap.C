#include <caml/mlvalues.h>
#include <caml/memory.h>
#include "Solver.h"

Solver *solver = new Solver();

static void convert_literals(value l, vec<Lit> &r) {
  while(Int_val(l) != 0) {
    Lit lit = toLit(Int_val(Field(l, 0)));
    r.push(lit);
    l = Field(l, 1);
  }
}

extern "C" value minisat_reset(value unit) {
  delete solver;
  solver = new Solver();

  return Val_unit;
}

extern "C" value minisat_new_var(value unit) {
  Var var = solver->newVar();
  return Val_int(var);
}

extern "C" value minisat_pos_lit(value v) {
  Var var = Int_val(v);
  Lit lit(var, false);
  return Val_int(index(lit));
}

extern "C" value minisat_neg_lit(value v) {
  Var var = Int_val(v);
  Lit lit(var, true);
  return Val_int(index(lit));
}

extern "C" value minisat_add_clause(value c) {
  vec<Lit> clause;
  convert_literals(c, clause);
  solver->addClause(clause);

  return Val_unit;
}

extern "C" value minisat_simplify_db(value unit) {
  solver->simplifyDB();

  return Val_unit;
}

extern "C" value minisat_solve(value unit) {
  value r;

  if(solver->solve()) {
    r = Val_int(0);
  } else {
    r = Val_int(1);
  }

  return r;
}

extern "C" value minisat_solve_with_assumption(value a) {
  vec<Lit> assumption;
  convert_literals(a, assumption);
  value r;

  if(solver->solve(assumption)) {
    r = Val_int(0);
  } else {
    r = Val_int(1);
  }

  return r;
}

extern "C" value minisat_value_of(value v) {
  Var var = Int_val(v);
  lbool val = solver->model[var];
  value r;

  if(val == l_False) {
    r = Val_int(0);
  } else if(val == l_True) {
    r = Val_int(1);
  } else if (val == l_Undef) {
    r = Val_int(2);
  } else {
    assert(0);
  }

  return r;
}
