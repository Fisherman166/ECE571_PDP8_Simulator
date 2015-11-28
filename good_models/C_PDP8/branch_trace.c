/******************************************************************************
** ECE486/586 PDP-8 Simulator
** Sean Koppenhafer, Luis Santiago, Ken
**
** branch_trace.c
*/

#include "branch_trace.h"

/* Declare branch text types */
const char* const unconditional_text = "Unconditional";
const char* const conditional_text = "Conditional";
const char* const sub_text = "Subroutine";

/******************************************************************************
** THIS FUNCTIONS OPENS THE BRANCH TRACE FILE
******************************************************************************/
int branch_trace_init(void) {
	const char* trace_name = "branch_trace_golden.txt";
	int retval = 0;
	branch_file = fopen(trace_name, "w");

	if(branch_file == NULL) {
		#ifdef TRACE_DEBUG
		printf("ERROR: Failed to open branch trace file.\n");
		#endif
		retval = -2;
	}
	else {
		#ifdef TRACE_DEBUG
		printf("Branch trace file opened successfully\n");
		#endif
		retval = 0;
	}

	return retval;
}

/*******************************************************************************
** THIS FUNCTION WRITES TO THE BRANCH TRACE FILE
** IT TAKES IN THE CURRENT PC, THE INSTRUCTION NAME, AND THE BRANCH TARGET
** TAKEN = 0 MEANS NOT TAKEN, TAKEN = 1 MEANS BRANCH TAKEN
******************************************************************************/
void write_branch_trace(uint16_t PC, uint16_t target_address, const char* opcode, uint8_t taken) {
	char result_text[10];

	if(taken) strcpy(result_text, "Taken");
	else strcpy(result_text, "Not Taken");

	fprintf(branch_file, "Current PC: %04o, Target: %04o, Type: %s, Result: %s\n", PC,
				target_address, opcode, result_text);
}

int close_branch_trace(void) {
	int retval;

	retval = fclose(branch_file);

	return retval;
}

