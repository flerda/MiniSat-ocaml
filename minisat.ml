
type minisat
type var = int
type lit = int
type value = False | True | Unknown
type solution = SAT | UNSAT

external create : unit -> minisat = "minisat_new"
external destroy : minisat -> unit = "minisat_del"
external new_var : minisat -> var = "minisat_new_var"
external pos_lit : var -> lit = "minisat_pos_lit"
external neg_lit : var -> lit = "minisat_neg_lit"
external add_clause : minisat -> lit list -> unit = "minisat_add_clause"
external simplify : minisat -> unit = "minisat_simplify"
external solve : minisat -> solution = "minisat_solve"
external solve_with_assumption : minisat -> lit list -> solution = "minisat_solve_with_assumption"
external __value_of : minisat -> var -> int = "minisat_value_of"

class solver = object (self)
  val solver = create ()
  method new_var = new_var solver
  method add_clause l = add_clause solver l
  method simplify = simplify solver
  method solve = solve solver
  method solve_with_assumption l = solve_with_assumption solver l
  method value_of v =
    match __value_of solver v with
    |0 -> False
    |1 -> True
    |2 -> Unknown
    |_ -> assert false
end

let string_of_value = function
  |False -> "false"
  |True -> "true"
  |Unknown -> "unknown"
