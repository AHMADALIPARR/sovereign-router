#!/bin/sh
# build.sh — the user's build commands, verbatim.
# Requires: OCaml (ocamlopt), a macOS toolchain (clang + Foundation).
# This VM is Linux with no OCaml, so this script cannot run here.
# It runs on a macOS host with OCaml installed.

set -e

# 1. Compile the Isabelle extraction and FFI wrapper to a native object file (.o)
# ASSISTANT-ADJUSTED PATH: the user's command referenced torus_trace.ml
# in the current dir; in this layout it lives in extraction/.
# ASSISTANT-ADJUSTED NAME: the file is TorusTrace.ml (capital T), not
# torus_trace.ml — OCaml derives the module name from the file name,
# and trace_export.ml does `open TorusTrace`. A lowercase
# torus_trace.ml compiles to module Torus_trace, and the build fails
# with "Unbound module TorusTrace". Isabelle writes torus_trace.ml;
# rename it to TorusTrace.ml (or the module name breaks).
ocamlopt -output-obj -o trace_backend.o extraction/TorusTrace.ml ocaml/trace_export.ml

# 2. Compile the Objective-C router and link the OCaml embedded runtime
clang -o sovereign_router objc/Router.m trace_backend.o \
      -I $(ocamlopt -where) \
      -L $(ocamlopt -where) -lasmrun -lm -ldl -fobjc-arc \
      -framework Foundation

# 3. Execute the bare-metal binary
./sovereign_router
