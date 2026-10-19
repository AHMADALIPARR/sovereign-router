theory Torus_Trace
  imports Main "HOL.Code_Numeral"
begin

record octonion_state =
  r :: integer
  e1 :: integer
  e2 :: integer
  e3 :: integer
  e4 :: integer
  e5 :: integer
  e6 :: integer
  e7 :: integer

definition state_trace :: "octonion_state => integer" where
  "state_trace q = r q + r q"

definition trace_scalar :: "integer => integer" where
  "trace_scalar b = state_trace
    (| r = b, e1 = 0, e2 = 0, e3 = 0, e4 = 0, e5 = 0, e6 = 0, e7 = 0 |)"

theorem trace_is_twice_real: "state_trace q = 2 * r q"
  by (simp add: state_trace_def numeral_eq_Suc)

theorem scalar_trace_exact: "trace_scalar b = 2 * b"
  by (simp add: trace_scalar_def state_trace_def numeral_eq_Suc)

theorem trace_nonnegative: "0 <= r q ==> 0 <= state_trace q"
  by (simp add: state_trace_def)

export_code trace_scalar state_trace in OCaml module_name TorusTrace
  file_prefix TorusTrace

end
