let trace_ffi decimal =
  let budget = Z.of_string decimal in
  if Z.sign budget < 0 || Z.compare budget (Z.of_string "2147483647") > 0
  then invalid_arg "budget outside checked uint32 domain";
  TorusTrace.TorusTrace.trace_scalar budget |> Z.to_string

let () = Callback.register "torus_trace_calc" trace_ffi
