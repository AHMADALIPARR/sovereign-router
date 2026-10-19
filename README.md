# Sovereign Trace Router

An Isabelle/HOL specification of the octonion trace t(q)=2 Re(q), exported to
OCaml and invoked from Objective-C through the OCaml embedding API. A checked C
reference and a complete Block II AGC routine provide bounded integer variants.

## Build the verified-source backend

Requires Isabelle2025-2, OCaml with Findlib and Zarith, GCC, and Foundation on
macOS or GNUstep development libraries on Linux.

```sh
ISABELLE=/path/to/Isabelle2025-2/bin/isabelle sh build.sh
.build/sovereign_router 9959
.build/sovereign_router 9959 trace-ledger.jsonl
```

The executable returns a JSON record containing budget 9959 and trace 19918.
The optional ledger path receives an appended JSON line. A write failure returns
an error; the ledger is a local append log, not a WORM or cryptographic store.

`build.sh` checks the Isabelle session, exports the actual generated OCaml,
compiles it with Zarith, embeds the runtime and links the Objective-C program.
`extraction/TorusTrace.ml` is generated output from the checked theory. The
build regenerates it rather than accepting an alternative handwritten backend.

## Numeric contracts

The theorem uses arbitrary-precision integers and proves trace equals twice
the real component. The Objective-C and checked C entry points accept budgets
0..2147483647, keeping the result representable as uint32. Invalid or overflowing
input is rejected. The legacy `calculate_torus_trace` function preserves C's
unsigned wrap semantics for compatibility; use its checked counterpart for the
bounded mathematical contract.

The AGC source has all labels and registers defined. It accepts positive
fixed-point budgets 0..8191 and returns TRACE with STATUS=0; arithmetic overflow
returns STATUS=1 and TRACE=0. It has been assembled with Virtual AGC yaYUL with
zero errors or warnings. Physical AGC execution and emulator execution have not
been validated. It is a callable routine, not an AGC executive or device image.

## Tests

```sh
gcc -Wall -Wextra -Werror c/torus_trace.c test/trace_test.c -o .build/trace_test
.build/trace_test
python3 test/router_test.py
# With yaYUL on PATH:
(cd agc && yaYUL torus_trace.agc)
```

Executed checks cover the Isabelle session, generated OCaml compilation,
Objective-C-to-OCaml calls, ledger output, invalid arguments, numeric boundaries
and 10,000 generated C cases. Linux/GNUstep was tested; the macOS link path is
provided but has not been executed here. The proof establishes the HOL function;
the foreign-function boundary is tested separately, not formally verified.

License: see LICENSE.
