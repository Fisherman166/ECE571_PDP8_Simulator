/******************************************************************************
** ECE486/586 PDP-8 Simulator
** Sean Koppenhafer, Luis Santiago, Ken Benderly, J.S. Peirce
**
** cpu.h
**
******************************************************************************/

#ifndef CPU_H
#define CPU_H

#include <stdio.h>
#include <inttypes.h>
#include <assert.h>
#include "kb_input.h"

#define CUTOFF_MASK 0xFFF	/* Bitmask to keep registers/memory at 12 bits */
#define STARTING_ADDRESS 0200	// start at 200 octal

#define OP_CODE_AND		0
#define OP_CODE_TAD		01000
#define OP_CODE_ISZ		02000
#define OP_CODE_DCA		03000
#define OP_CODE_JMS		04000
#define OP_CODE_JMP		05000
#define OP_CODE_IO		06000
#define OP_CODE_MICRO	07000

#define IO_OPCODE_BITS_MASK 0077
#define MICRO_INSTRUCTION_GROUP_BIT 0400
#define MICRO_INSTRUCTION_BITS_MASK 0377
#define MICRO_GROUP2_SUBGROUP_BIT 00010

// I/O Keyboard
#define IO_OPCODE_KCF_BITS 0030
#define IO_OPCODE_KSF_BITS 0031
#define IO_OPCODE_KCC_BITS 0032
#define IO_OPCODE_KRS_BITS 0034
#define IO_OPCODE_KRB_BITS 0036

// I/O Monitor
#define IO_OPCODE_TFL_BITS 0040
#define IO_OPCODE_TSF_BITS 0041
#define IO_OPCODE_TCF_BITS 0042
#define IO_OPCODE_TPC_BITS 0044
#define IO_OPCODE_TLS_BITS 0046

// Group 1 micro instructions
#define MICRO_INSTRUCTION_CLA_BITS	0200
#define MICRO_INSTRUCTION_CLL_BITS	0100
#define MICRO_INSTRUCTION_CMA_BITS	0040
#define MICRO_INSTRUCTION_CML_BITS	0020
#define MICRO_INSTRUCTION_IAC_BITS	0001
#define MICRO_INSTRUCTION_RAR_BITS	0010
#define MICRO_INSTRUCTION_RTR_BITS	0012
#define MICRO_INSTRUCTION_RAL_BITS	0004
#define MICRO_INSTRUCTION_RTL_BITS	0006

// Group 2 micro instructions
#define MICRO_INSTRUCTION_SMA_BITS	0100
#define MICRO_INSTRUCTION_SZA_BITS	0040
#define MICRO_INSTRUCTION_SNL_BITS	0020
#define MICRO_INSTRUCTION_SPA_BITS	0110
#define MICRO_INSTRUCTION_SNA_BITS	0050
#define MICRO_INSTRUCTION_SZL_BITS	0030
#define MICRO_INSTRUCTION_SKP_BITS	0010
#define MICRO_INSTRUCTION_CLA_BITS	0200
#define MICRO_INSTRUCTION_OSR_BITS	0004
#define MICRO_INSTRUCTION_HLT_BITS	0002

/* CPU registers - only 12 bits are used of the 16 */
typedef struct {
	uint16_t AC;		/* Accumulator */
	uint16_t MQ;		/* Multiplier Quotient */
	uint16_t PC;		/* Program Counter */
	uint16_t MB;		/* Memory Buffer */
	uint16_t CPMA;		/* Central Processor Memory Address */
	uint16_t SR;		/* Console Switch Register */
	uint8_t IR;			/* Instruction Register - only 3 bits are used */
	uint8_t link_bit;	/* Carry out bit */
	uint8_t print_flag;
} regs;

/* Opcodes 0-5 - Memory reference functions */
void AND(regs*);
void TAD(regs*);
void ISZ(regs*);
void DCA(regs*);
void JMS(regs*);
void JMP(regs*);

/* Opcode 6 - I/O - Keyboard */
void KCF(struct keyboard*);
void KSF(regs*, struct keyboard*);
void KCC(regs*, struct keyboard*);
void KRS(regs*, struct keyboard*);
void KRB(regs*, struct keyboard*);

/* Opcode 6 - I/O - Monitor */
void TFL(regs*);
void TSF(regs*);
void TCF(regs*);
void TPC(regs*);
void TLS(regs*);

/* Opcode 7 - group 1 */
void CLA(regs*);
void CLL(regs*);
void CMA(regs*);
void CML(regs*);
void IAC(regs*);
void RAR(regs*);
void RTR(regs*);
void RAL(regs*);
void RTL(regs*);

/* Opcoderegs* 7 - group 2 */
uint8_t SMA(regs*);
uint8_t SZA(regs*);
uint8_t SNL(regs*);
uint8_t SPA(regs*);
uint8_t SNA(regs*);
uint8_t SZL(regs*);
void SKP(regs*);
void OSR(regs*);
void HLT(struct keyboard*);

/* Reset the registers */
void reset_regs(regs*);

#endif

