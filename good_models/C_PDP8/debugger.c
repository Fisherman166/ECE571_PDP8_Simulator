// debugger.c

#include <stdio.h>
#include "debugger.h"
#define DEBUGGER_ARG_POSITION 4

typedef enum debugger_tag {OFF, PAUSE, STEP, NEXT, RUN} DEBUGGER_STATE;

// local globals
static DEBUGGER_STATE state = OFF;

/******************************************************************************
 * 	INITIALLIZE DEBUGGER
 * 	@arg int argc, lchar * argv[]
 * 	@return NONE
 *****************************************************************************/
void debugger_init(int argc, char* argv[]){
	if(argc == DEBUGGER_ARG_POSITION && argv[DEBUGGER_ARG_POSITION - 1][0] == 'd'){
		printf("debugger: = %s\n", argv[DEBUGGER_ARG_POSITION - 1]);
		state = PAUSE;
	}
}//END DEBUG_INIT
/******************************************************************************
 * 	DEBUGGER _POST_PROGRAM_RUN
 * 	@arg NONE
 * 	@return NONE
 *****************************************************************************/

void debugger_post_program_run(void){
	printf("shutting down debugger\n");
	state = OFF;
}

/******************************************************************************
 * 	DEBUGGER_PRE_INSTRUCTION_FETCH
 * 	@arg regs *registers
 * 	@return NONE
 *****************************************************************************/
void debugger_pre_instruction_fetch(regs *registers){
	char s[80];

	printf("PC: %o, enter to continue: ", registers->PC);
	gets(s);
}
/******************************************************************************
 * 	DEBUGGER_RUNNING
 * 	@arg NONE
 * 	@return state, 0 if not running, 1 if running
 *****************************************************************************/
//I CHANGED THESE TO BE A LITTLE SIMPLER TO READ, IF IT BREAKS SOMETHING
//SWITCH IT BACK, IF IT WORKS AND YOU LIKE IT, KEEP IT
unsigned int debugger_running(void){
	if(state == OFF)
		return state;//return(0);	
	else 
		state = PAUSE;//return(1);
	return state;
}
/******************************************************************************
 * 	EOF
 *****************************************************************************/
