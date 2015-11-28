/******************************************************************************
** ECE486/586 PDP-8 Simulator
** Sean Koppenhafer, Luis Santiago, Ken Benderly, J.S. Peirce
**
** cpu.c
**
******************************************************************************/

#include "cpu.h"
#include "memory.h"
#include "branch_trace.h"

/******************************************************************************
** OPCODE 0 - AND
******************************************************************************/
void AND(regs* registers) {
	registers->MB = mem_read(registers->CPMA, DATA_READ);
	registers->AC &= registers->MB;
}

/******************************************************************************
** OPCODE 1 - TAD
******************************************************************************/
void TAD(regs* registers) {
	const uint16_t carry_out = 0x1000;	/* Check bit 13 for carry out */
	registers->MB = mem_read(registers->CPMA, DATA_READ);
	registers->AC += registers->MB;

	//Keep only the first bit after complimenting
	if(registers->AC & carry_out) registers->link_bit = (~registers->link_bit) & 1;

	registers->AC &= CUTOFF_MASK;
}

/******************************************************************************
** OPCODE 2 - ISZ
******************************************************************************/
void ISZ(regs* registers) {
	uint8_t taken = 0;
	uint16_t current_PC = registers->PC;

	registers->MB = mem_read(registers->CPMA, DATA_READ);
	registers->MB = (registers->MB + 1) & CUTOFF_MASK;
	mem_write(registers->CPMA, registers->MB);

	if(!registers->MB) {
		registers->PC++;
		taken = 1;
	}

	write_branch_trace(current_PC, current_PC + 1, conditional_text, taken);
}

/******************************************************************************
** OPCODE 3 - DCA
******************************************************************************/
void DCA(regs* registers) {
	registers->MB = registers->AC;
	mem_write(registers->CPMA, registers->MB);
	registers->AC = 0;
}

/******************************************************************************
** OPCODE 4 - JMS
******************************************************************************/
void JMS(regs* registers) {
	uint8_t taken = 1;
	uint16_t current_PC = registers->PC;

	registers->MB = registers->PC; 
	mem_write(registers->CPMA, registers->MB);
	registers->PC = (registers->CPMA + 1) & CUTOFF_MASK; //Start 1 address into sub

	write_branch_trace(current_PC, registers->PC, sub_text, taken);
}

/******************************************************************************
** OPCODE 5 - JMP
******************************************************************************/
void JMP(regs* registers) {
	uint8_t taken = 1;
	uint16_t current_PC = registers->PC;

	registers->PC = registers->CPMA;

	write_branch_trace(current_PC, registers->PC, unconditional_text, taken);
}

/******************************************************************************
** OPCODE 6 - Keyboard - KCF
******************************************************************************/
void KCF(struct keyboard* kb_state) {
	pthread_mutex_lock(&keyboard_mux);
	kb_state->input_flag = 0;
	pthread_mutex_unlock(&keyboard_mux);
}

/******************************************************************************
** OPCODE 6 - Keyboard - KSF
******************************************************************************/
void KSF(regs* registers, struct keyboard* kb_state) {
	uint8_t taken = 0;
	uint16_t current_PC = registers->PC;

	pthread_mutex_lock(&keyboard_mux);
	if(kb_state->input_flag) {
		registers->PC++;
		taken = 1;
	}
	pthread_mutex_unlock(&keyboard_mux);
	write_branch_trace(current_PC, current_PC + 1, conditional_text, taken);
}

/******************************************************************************
** OPCODE 6 - Keyboard - KCC
******************************************************************************/
void KCC(regs* registers, struct keyboard* kb_state) {
	CLA(registers);
	pthread_mutex_lock(&keyboard_mux);
	kb_state->input_flag = 0;
	pthread_mutex_unlock(&keyboard_mux);
}

/******************************************************************************
** OPCODE 6 - Keyboard - KRS
******************************************************************************/
void KRS(regs* registers, struct keyboard* kb_state) {
	pthread_mutex_lock(&keyboard_mux);
		registers->AC |= kb_state->input_char << 4;
	pthread_mutex_unlock(&keyboard_mux);
}

/******************************************************************************
** OPCODE 6 - Keyboard - KRB
******************************************************************************/
void KRB(regs* registers, struct keyboard* kb_state) {
	registers->AC = 0;
	pthread_mutex_lock(&keyboard_mux);
		kb_state->input_flag = 0;
		registers->AC |= kb_state->input_char << 4;
	pthread_mutex_unlock(&keyboard_mux);
}

/******************************************************************************
** OPCODE 6 - Monitor - TFL
******************************************************************************/
void TFL(regs* registers) {
	registers->print_flag = 1;
}

/******************************************************************************
** OPCODE 6 - Monitor - TSF
******************************************************************************/
void TSF(regs* registers) {
	uint8_t taken = 0;
	uint16_t current_PC = registers->PC;

	if(registers->print_flag) {
		registers->PC++;
		taken = 1;
	}

	write_branch_trace(current_PC, current_PC + 1, conditional_text, taken);
}

/******************************************************************************
** OPCODE 6 - Monitor - TCF
******************************************************************************/
void TCF(regs* registers) {
	registers->print_flag = 0;
}

/******************************************************************************
** OPCODE 6 - Monitor - TPC
******************************************************************************/
void TPC(regs* registers) {
	char to_print = (registers->AC >> 4) & 0xFF;
	printf("%c", to_print);
	fflush(stdout);
}

/******************************************************************************
** OPCODE 6 - Monitor - TLS
******************************************************************************/
void TLS(regs* registers) {
	registers->print_flag = 0;
	char to_print = (registers->AC >> 4) & 0xFF;
	printf("%c", to_print);
}

/******************************************************************************
** OPCODE 7 GROUP 1 - CLA
******************************************************************************/
void CLA(regs* registers) {
	registers->AC = 0;
}

/******************************************************************************
** OPCODE 7 GROUP 1 - CLL
******************************************************************************/
void CLL(regs* registers) {
	registers->link_bit = 0;
}

/******************************************************************************
** OPCODE 7 GROUP 1 - CMA
******************************************************************************/
void CMA(regs* registers) {
	registers->AC = ~registers->AC & CUTOFF_MASK;
}

/******************************************************************************
** OPCODE 7 GROUP 1 - CML
******************************************************************************/
void CML(regs* registers) {
	registers->link_bit = ~registers->link_bit & 1;
}

/******************************************************************************
** OPCODE 7 GROUP 1 - IAC
******************************************************************************/
void IAC(regs* registers) {
	registers->AC = (registers->AC + 1) & CUTOFF_MASK;
}

/******************************************************************************
** OPCODE 7 GROUP 1 - RAR
******************************************************************************/
void RAR(regs* registers) {
	const uint8_t bit11_shift = 11;
	uint8_t old_link = registers->link_bit;

	/* Shift right 1.  New link is bit 0 of registers->AC.
	** Bit 11 of new registers->AC is old link bit value.
	*/
	registers->link_bit = registers->AC & 1;
	registers->AC >>= 1;
	registers->AC = (registers->AC | (old_link << bit11_shift)) & CUTOFF_MASK;
}

/******************************************************************************
** OPCODE 7 GROUP 1 - RTR
******************************************************************************/
void RTR(regs* registers) {
	/* Same as two RAR in a row */
	RAR(registers);
	RAR(registers);
}

/******************************************************************************
** OPCODE 7 GROUP 1 - RAL
******************************************************************************/
void RAL(regs* registers) {
	const uint8_t shift_num = 12;	/* Shift bit 12 into bit 0 */
	const uint16_t new_link_pos = 0x1000;	/* Bit 12 */

	/* Shift registers->AC left 1.  New link is bit 12
	** Bit 0 of registers->AC is old link bit
	*/
	registers->AC <<= 1;
	registers->AC |= registers->link_bit;
	registers->link_bit = (registers->AC & new_link_pos) >> shift_num;
	registers->AC &= CUTOFF_MASK;
}

/******************************************************************************
** OPCODE 7 GROUP 1 - RTL
******************************************************************************/
void RTL(regs* registers) {
	/* Same as two RAL in a row */
	RAL(registers);
	RAL(registers);
}

/******************************************************************************
** OPCODE 7 GROUP 2 - SMA
******************************************************************************/
uint8_t SMA(regs* registers) {
	const uint16_t sign_bit = 0x800;
	uint8_t retval = 0;

	if(registers->AC & sign_bit) {
		retval = 1;
	}
	return retval;
}

/******************************************************************************
** OPCODE 7 GROUP 2 - SZA
******************************************************************************/
uint8_t SZA(regs* registers) {
	uint8_t retval = 0;

	if(!registers->AC) {
		retval = 1;
	}
	return retval;
}

/******************************************************************************
** OPCODE 7 GROUP 2 - SNL
******************************************************************************/
uint8_t SNL(regs* registers) {
	uint8_t retval = 0;

	if(registers->link_bit) {
		retval = 1;
	}
	return retval;
}

/******************************************************************************
** OPCODE 7 GROUP 2 - SPA
******************************************************************************/
uint8_t SPA(regs* registers) {
	const uint16_t sign_bit = 0x800;
	uint8_t retval = 0;

	if( !(registers->AC & sign_bit) ) {
		retval = 1;
	}
	return retval;
}

/******************************************************************************
** OPCODE 7 GROUP 2 - SNA
******************************************************************************/
uint8_t SNA(regs* registers) {
	uint8_t retval = 0;

	if(registers->AC) {
		retval = 1;
	}
	return retval;
}

/******************************************************************************
** OPCODE 7 GROUP 2 - SZL
******************************************************************************/
uint8_t SZL(regs* registers) {
	uint8_t retval = 0;

	if(!registers->link_bit) {
		retval = 1;
	}
	return retval;
}

/******************************************************************************
** OPCODE 7 GROUP 2 - SKP
******************************************************************************/
void SKP(regs* registers) {
	uint8_t taken = 1;
	
	write_branch_trace(registers->PC, registers->PC + 1, unconditional_text, taken);
	registers->PC++;
}

/******************************************************************************
** OPCODE 7 GROUP 2 - OSR
******************************************************************************/
void OSR(regs* registers) {
	registers->AC = (registers->AC | registers->SR) & CUTOFF_MASK;
}

/******************************************************************************
** OPCODE 7 GROUP 2 - HLT
******************************************************************************/
void HLT(struct keyboard* kb_state) {
	printf("\n\nHALTING SYSTEM\n");

	pthread_mutex_lock(&keyboard_mux);
	kb_state->quit = 1;
	pthread_mutex_unlock(&keyboard_mux);
}

/******************************************************************************
** RESET REGISTER VALUES
******************************************************************************/
void reset_regs(regs* registers) {
	registers->PC = STARTING_ADDRESS;
	registers->AC = 0;
	registers->MQ = 0;
	registers->link_bit = 0;
	registers->CPMA = 0;
	registers->MB = 0;
	registers->SR = 0;
	registers->IR = 0;
	registers->print_flag = 0;
}

