
#include <minisat2/Solver.h>

extern "C"
{
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
}

/* Declaring the functions which should be accessible on the C side. */
extern "C" 
{
  CAMLprim value minisat_new(value solver);
  CAMLprim value minisat_del(value solver);
  CAMLprim value minisat_new_var(value solver);
  CAMLprim value minisat_pos_lit(value v);
  CAMLprim value minisat_neg_lit(value v);
  CAMLprim value minisat_add_clause(value solver, value c);
  CAMLprim value minisat_simplify(value solver);
  CAMLprim value minisat_solve(value solver);
  CAMLprim value minisat_solve_with_assumption(value solver, value a);
  CAMLprim value minisat_value_of(value solver, value v);
}

static void convert_literals(value l, vec<Lit> &r) {
  while(Int_val(l) != 0) {
    Lit lit = toLit(Int_val(Field(l, 0)));
    r.push(lit);
    l = Field(l, 1);
  }
}

CAMLprim value minisat_new(value unit) {
  CAMLparam0 ();
  CAMLlocal1 (result);
  Solver *solver = new Solver();
  result = alloc_small(1, Abstract_tag);
  Field(result, 0) = (value) solver;

  CAMLreturn(result);
}

#define solver_val(v) ((Solver*)(Field((v), 0)))

CAMLprim value minisat_del(value solver) {
  CAMLparam1 (solver);
  Solver *_solver;
  _solver = solver_val(solver);
  delete _solver;
  CAMLreturn(Val_unit);
}

CAMLprim value minisat_new_var(value solver) {
  CAMLparam1 (solver);
  Solver *_solver;
  _solver = solver_val(solver);
  Var var = _solver->newVar();
  return Val_int(var);
}

CAMLprim value minisat_pos_lit(value v) {
  Var var = Int_val(v);
  Lit lit(var, false);
  return Val_int(toInt(lit));
}

CAMLprim value minisat_neg_lit(value v) {
  Var var = Int_val(v);
  Lit lit(var, true);
  return Val_int(toInt(lit));
}

CAMLprim value minisat_add_clause(value solver, value c) {
  CAMLparam2 (solver, c);
  CAMLlocal1 (result);

  Solver* _solver = solver_val(solver);

  vec<Lit> clause;
  convert_literals(c, clause);
  _solver->addClause(clause);

  result = alloc_small(1, Abstract_tag);
  Field(result, 0) = (value) _solver;

  CAMLreturn(result);
}

CAMLprim value minisat_simplify(value solver) {
  CAMLparam1 (solver);
  CAMLlocal1 (result);

  Solver* _solver = solver_val(solver);
  _solver->simplify();

  result = alloc_small(1, Abstract_tag);
  Field(result, 0) = (value) _solver;

  CAMLreturn(result);
}

CAMLprim value minisat_solve(value solver) {
  CAMLparam1 (solver);
  CAMLlocal1 (result);

  Solver* _solver = solver_val(solver);
  if(_solver->solve()) {
    result = Val_int(0);
  } else {
    result = Val_int(1);
  }

  CAMLreturn(result);
}

CAMLprim value minisat_solve_with_assumption(value solver, value a) {
  CAMLparam2 (solver, a);
  CAMLlocal1 (result);

  vec<Lit> assumption;
  convert_literals(a, assumption);

  Solver* _solver = solver_val(solver);

  if(_solver->solve(assumption)) {
    result = Val_int(0);
  } else {
    result = Val_int(1);
  }

  CAMLreturn(result);
}

CAMLprim value minisat_value_of(value solver, value v) {
  CAMLparam2 (solver,v);
  CAMLlocal1 (result);

  Solver* _solver = solver_val(solver);

  Var var = Int_val(v);
  lbool val = _solver->model[var];

  if(val == l_False) {
    result = Val_int(0);
  } else if(val == l_True) {
    result = Val_int(1);
  } else if (val == l_Undef) {
    result = Val_int(2);
  } else {
    assert(0);
  }

  CAMLreturn(result);
}

