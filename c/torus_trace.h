#ifndef TORUS_TRACE_H
#define TORUS_TRACE_H
#include <stdint.h>
uint32_t calculate_torus_trace(uint32_t temporal_budget);
int calculate_torus_trace_checked(uint32_t temporal_budget, uint32_t *trace);
#endif
