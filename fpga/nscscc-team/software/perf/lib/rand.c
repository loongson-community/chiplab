static unsigned long next = 0xDEEDBEEF;

int rand(void) {
    next = next * 1103515245 + 12345;
    return (unsigned int)(next/65536) % 32768;
}
void srand(unsigned int seed) {
    next = seed;
}
