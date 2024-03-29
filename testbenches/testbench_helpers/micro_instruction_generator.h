#ifndef MICRO_INSTRUCTION_GENERATOR_H
#define MICRO_INSTRUCTION_GENERATOR_H

#include <stdio.h>
#include <inttypes.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#define I_REG_MASK 0x1FF
#define AC_REG_MASK 0xFFF
#define SINGLE_BIT 0x1
#define OPCODE_TEXT_SIZE 100

typedef struct {
    uint16_t i_reg;
    uint16_t ac_reg;
    uint8_t l_reg;
    uint16_t result_ac;
    uint8_t result_link;
    uint8_t skip;
    uint8_t micro_g1;
    uint8_t micro_g2;
    uint8_t micro_g3;
    char opcodes[OPCODE_TEXT_SIZE];
} regs;

// Test helper functions
void run_exhaustive_test(void (*opcode) (regs*, uint16_t, uint8_t), regs*, FILE*);
void run_single_test(void (*opcode) (regs*, uint16_t, uint8_t), regs*, uint16_t, FILE*);
void write_regs(regs*, FILE*);

//Group 1 test functions
void group1_single_tests(regs*, FILE*);
void group1_exhaustive_tests(regs*, FILE*);
void group1_directed_tests(regs*, FILE*);

//Group 2 test functions
void group2_single_tests(regs*, FILE*);
void group2_exhaustive_tests(regs*, FILE*);
void group2_or_directed_tests(regs*, FILE*);
void group2_and_directed_tests(regs*, FILE*);

void group3_tests(regs*, FILE*);

/* Opcode 7 - group 1 */
void CLA(regs*, uint16_t, uint8_t);
void CLL(regs*, uint16_t, uint8_t);
void CMA(regs*, uint16_t, uint8_t);
void CML(regs*, uint16_t, uint8_t);
void IAC(regs*, uint16_t, uint8_t);
void RAR(regs*, uint16_t, uint8_t);
void RTR(regs*, uint16_t, uint8_t);
void RAL(regs*, uint16_t, uint8_t);
void RTL(regs*, uint16_t, uint8_t);

/* Opcode 7 - group 2 */
void SMA(regs*, uint16_t, uint8_t);
void SZA(regs*, uint16_t, uint8_t);
void SNL(regs*, uint16_t, uint8_t);
void SPA(regs*, uint16_t, uint8_t);
void SNA(regs*, uint16_t, uint8_t);
void SZL(regs*, uint16_t, uint8_t);

/* Opcode 7 - group 3 */
void MQL(regs*, uint16_t, uint8_t);

#endif

