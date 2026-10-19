# Sovereign Router — Octonion Prime Trace Extraction (A_89/2462)

The trace of an 8D octonion state is twice its real part: `t(q) = 2 * Re(q)`.
This repo implements that trace four ways, all agreeing:

| Implementation | File | Status |
|---|---|---|
| C reference | `torus_trace.c` | **Verified by execution** (9959 → 19918) |
| OCaml FFI wrapper | `trace_export.ml` | Written (needs OCaml + macOS to build) |
| Objective-C router | `Router.m` | Written (needs macOS Foundation) |
| AGC core-rope kernel | `agc/torus_trace.agc` | Written, not executed (no AGC emulator) |

The Isabelle/HOL extraction (`extraction/TorusTrace.ml`) is the
verified source. It has **not been generated yet** — the file in
`extraction/` is an assistant-written stand-in (labeled in-file)
implementing the same function, so the FFI + router build can be
exercised. Replace it with the real `export_code` output (and rename
it to `TorusTrace.ml` — OCaml derives the module name from the file
name, and `trace_export.ml` does `open TorusTrace`).

## The flow

1. Isabelle/HOL defines `state_trace` and extracts it to OCaml
   (`extraction/README.md` has the `export_code` command).
2. `trace_export.ml` wraps it (`trace_ffi`) and registers it as the
   named callback `torus_trace_calc`.
3. `ocamlopt -output-obj` compiles the OCaml into a native object
   file embedding the OCaml runtime.
4. `Router.m` boots the OCaml runtime inside an Objective-C process,
   resolves `torus_trace_calc` by name, and invokes the verified
   theorem across the C boundary (`Val_int` in, `Int_val` out).
5. The prime trace can be piped to the objc-router/metal bridge.

The AGC kernel does the same computation on the Apollo Guidance
Computer: load `R(q)`, add `R(q)`, store to the trace ledger.

## Build (macOS + OCaml)

```bash
./build.sh
```

Runs: `ocamlopt` (extraction + FFI → `trace_backend.o`), `clang`
(`Router.m` + runtime → `sovereign_router`), then `./sovereign_router`.
Expected output for the example budget 9959: prime trace **19918**.

## C reference (verified here)

```bash
gcc -O2 -o test_torus test_torus.c   # test harness, not in repo
./test_torus
# 9959 -> 19918, 0 -> 0, 1 -> 2
```

Verified on this VM (gcc 13.3, Linux). The OCaml + Obj-C path needs
macOS (Foundation) + OCaml and cannot run on this Linux VM.

## License

SNAPKITTY OPAQUE SOURCE LICENSE v1.0 — see `LICENSE`.
