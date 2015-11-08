#ifndef MICRO_INSTRUCTION_GENERATOR_H
#define MICRO_INSTRUCTION_GENERATOR_H

#include <stdio.h>
#include <inttypes.h>
#include <unistd.h>
#include <stdlib.h>

#define I_REG_MASK 0x1FF
#define AC_REG_MASK 0xFFF
#define SINGLE_BIT 0x1

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
} regs;

void run_exhaustive_test(void (*opcode) (regs*, uint16_t, uint8_t), regs*, FILE*);
void write_regs(regs*, FILE*);

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

