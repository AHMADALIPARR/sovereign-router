#!/bin/sh
set -eu
cd "$(dirname "$0")"
ISABELLE=${ISABELLE:-isabelle}
mkdir -p .build/export extraction
"$ISABELLE" build -j 1 -o threads=1 -D isabelle Sovereign_Trace
"$ISABELLE" export -d isabelle -x 'Sovereign_Trace.Torus_Trace:code/TorusTrace.ocaml' -O .build/export Sovereign_Trace
generated=$(find .build/export -name TorusTrace.ocaml -type f)
test -n "$generated"
cp "$generated" extraction/TorusTrace.ml
ocamlfind ocamlopt -package zarith -I extraction -c extraction/TorusTrace.ml
ocamlfind ocamlopt -package zarith -I extraction -c ocaml/trace_export.ml
set --
if [ "$(uname -s)" = Linux ]; then set -- -cclib "-L/usr/lib/$(gcc -print-multiarch)"; fi
ocamlfind ocamlopt -package zarith -linkpkg "$@" -output-complete-obj -o .build/trace_backend.o extraction/TorusTrace.cmx ocaml/trace_export.cmx
case "$(uname -s)" in
  Darwin)
    clang -Wall -Wextra -o .build/sovereign_router objc/Router.m .build/trace_backend.o -I "$(ocamlc -where)" -framework Foundation -lgmp -lm -lpthread
    ;;
  Linux)
    gcc -Wall -Wextra $(gnustep-config --objc-flags) -I "$(ocamlc -where)" -o .build/sovereign_router objc/Router.m .build/trace_backend.o $(gnustep-config --base-libs) -lgmp -ldl -lpthread
    ;;
  *) printf '%s\n' 'Objective-C Foundation build requires macOS or GNUstep on Linux' >&2; exit 1;;
esac
printf '%s\n' 'Built .build/sovereign_router from Isabelle-generated OCaml.'
