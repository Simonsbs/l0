#include <stdint.h>
static uint64_t f1(uint64_t a, uint64_t b) { return a + b; }
uint64_t f0(uint64_t a, uint64_t b) { return f1(a, b); }
