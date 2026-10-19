module TorusTrace : sig
  type 'a octonion_state_ext
  val state_trace : unit octonion_state_ext -> Z.t
  val trace_scalar : Z.t -> Z.t
end = struct

type 'a octonion_state_ext =
  Octonion_state_ext of Z.t * Z.t * Z.t * Z.t * Z.t * Z.t * Z.t * Z.t * 'a;;

let rec r (Octonion_state_ext (ra, e1, e2, e3, e4, e5, e6, e7, more)) = ra;;

let rec state_trace q = Z.add (r q) (r q);;

let rec trace_scalar
  b = state_trace
        (Octonion_state_ext
          (b, Z.zero, Z.zero, Z.zero, Z.zero, Z.zero, Z.zero, Z.zero, ()));;

end;; (*struct TorusTrace*)
