(* trace_export.ml *)
open TorusTrace

(* Wrap the Isabelle trace to handle standard integers across the FFI *)
let trace_ffi (budget_scalar : int) : int =
  (* Assuming Isabelle mapped OctonionState to a record, 
     we instantiate the budget (R) to calculate t(q) *)
  let state = { r = budget_scalar; e1 = 0; e2 = 0; e3 = 0; e4 = 0; e5 = 0; e6 = 0; e7 = 0 } in
  state_trace state

(* Register the function so Objective-C can discover it via string name *)
let () = Callback.register "torus_trace_calc" trace_ffi
