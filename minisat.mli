
(** For more information http://minisat.se/MiniSat.html
 * and in particular to this paper : 
 * http://minisat.se/downloads/MiniSat.ps.gz
 *)

type minisat
type var = int
type lit = int
type value = False | True | Unknown
type solution = SAT | UNSAT

class solver :
  object
    val solver : minisat

    (** add a clause to the set of problem constraints. A clause is interpreted as 
     * a conjunction of positive and negative literals *)
    method add_clause : lit list -> unit

    (** create a new variable *)
    method new_var : var

    (** [simplify] can be called before [solve] to simply the set of problem
     * constrains. It will first propagate all unit information and the remove all
     * satisfied constraints *)
    method simplify : unit

    (** find a solution to the current sat problem *)
    method solve : solution

    method solve_with_assumption : lit list -> solution

    (** return the value associated to a variable *)
    method value_of : var -> value
  end

(** convert a value to a string *)
val string_of_value : value -> string

(** given a variable, returns a positive literal *)
external pos_lit : var -> lit = "minisat_pos_lit"

(** given a variable, returns a negative literal *)
external neg_lit : var -> lit = "minisat_neg_lit"
