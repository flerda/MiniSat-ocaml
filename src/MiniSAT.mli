type var = int
type lit = int
type value = int (* F | T | X *)
type solution = SAT | UNSAT

external reset : unit -> unit = "minisat_reset"
external new_var : unit -> var = "minisat_new_var"
external pos_lit : var -> lit = "minisat_pos_lit"
external neg_lit : var -> lit = "minisat_neg_lit"
external add_clause : lit list -> unit = "minisat_add_clause"
external simplify_db : unit -> unit = "minisat_simplify_db"
external solve : unit -> solution = "minisat_solve"
external solve_with_assumption : lit list -> solution = "minisat_solve_with_assumption"
external value_of : var -> value = "minisat_value_of"
val string_of_value : value -> string
