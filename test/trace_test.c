#include "../c/torus_trace.h"
#include <assert.h>
#include <stddef.h>
#include <stdio.h>
int main(void) {
    uint32_t out = 99;
    assert(calculate_torus_trace_checked(0, &out) && out == 0);
    assert(calculate_torus_trace_checked(9959, &out) && out == 19918);
    assert(calculate_torus_trace_checked(UINT32_MAX/2, &out) && out == UINT32_MAX-1);
    out = 99;
    assert(!calculate_torus_trace_checked(UINT32_MAX/2+1, &out) && out == 99);
    assert(!calculate_torus_trace_checked(1, NULL));
    uint32_t state = 1;
    for (unsigned i=0;i<10000;i++) {
        state = state * 1664525u + 1013904223u;
        uint32_t x = state/2;
        assert(calculate_torus_trace_checked(x, &out));
        assert((uint64_t)out == (uint64_t)x*2);
        assert(calculate_torus_trace(x) == out);
    }
    puts("C checked trace: boundary cases and 10000 generated inputs passed.");
}
