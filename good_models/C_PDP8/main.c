/******************************************************************************
** ECE486/586 PDP-8 Simulator
** Sean Koppenhafer, Luis Santiago, Ken Benderly
**
** main.c
*/

#include "main.h"
#include "memory.h"
#include "cpu.h"
#include "kb_input.h"
#include "branch_trace.h"
#include "debugger.h"
//#define MEMORY_DEBUG
#define OP_CODE_MASK 07000		// bits 0,1,2

static uint32_t clock_cycles = 0;
static uint32_t opcode_freq[OPCODE_NUM];
static uint8_t opcode_cycles[OPCODE_NUM] = {2,2,2,2,2,1,0,1};
static const char *opcode_text[OPCODE_NUM];

int main(int argc, char* argv[]) {
	int trace_return;
	int thread1, thread2;
	pthread_t keyboard_thread, simulator_thread;
	struct keyboard local_kb;	//Needed for I/O
	local_kb.input_flag = 0;
	local_kb.quit = 0;

	init_system(argc, argv);

	//can capture return values to verify fopen && fclose
	trace_return = trace_init();
	if(trace_return) {
		printf("Unable to open trace file. Exiting\n");
		exit(-1);
	}

	//Create a keyboard and a simulator thread for nonblocking I/O
	thread1 = pthread_create(&keyboard_thread, NULL, read_keyboard, (void*)&local_kb);
	if(thread1) {
		fprintf(stderr, "Keyboard thread failed\n");
		exit(-1);
   }

	thread2 = pthread_create(&simulator_thread, NULL, run_program, (void*)&local_kb);
	if(thread2) {
		fprintf(stderr, "Simulator thread failed\n");
		exit(-1);
   }

	//Run the threads
	pthread_join(keyboard_thread, NULL);
	pthread_join(simulator_thread, NULL);

	//run_program();
	mem_print_valid();
	////print_stats();
	trace_close();
	close_branch_trace();
	return(0);
}/*end main*/

/******************************************************************************
** 	RUN THE PROGRAM IN MEMORY 	
******************************************************************************/
void* run_program(void* keyboard_object){
	const uint8_t microinstruction = 7;
	char instruct_text[80];
	uint8_t subgroup_returns[3];
	uint8_t subgroup_taken;		//Will be 0 if branch not taken, 1 if taken
	uint16_t current_PC;			//Used for the branch trace file
	uint16_t current_instruction;
	uint8_t addressing_mode;
	regs registers;
	struct keyboard* local_kb = (struct keyboard*)keyboard_object;
	unsigned int running;
	unsigned int run_at_least_once = 1;
    FILE* opcode_file = fopen("opcodes_golden.txt", "w");

	reset_regs(&registers);		// initialize the CPU 

	while (debugger_running() || run_at_least_once){
		run_at_least_once = 0;
		running = 1;
		while(running){
			if (debugger_running()){
				debugger_pre_instruction_fetch(&registers);
			}
			current_instruction = mem_read(registers.PC, INSTRUCTION_FETCH);	// Has status bits still
			registers.PC++;																	// increment the PC
		
			registers.IR = (current_instruction >> 9) & 0x7;						// Put the opcode in here

			//Microinstructions don't have indirect or auto increment modes
			//Set the addressing mode to direct to not add additional cycles onto micro ops
			if(registers.IR != microinstruction) {
				addressing_mode = EffAddCalc(current_instruction, &registers);		// Load the CPMA with effective address
			}
			else {
				addressing_mode = DIRECT_MODE;
			}

			/* !update trace file here for instruction read! */
			switch(current_instruction & OP_CODE_MASK){
			case OP_CODE_AND:
				AND(&registers);
				strcpy(instruct_text, "AND");
				opcode_freq[0]++;
				break;
			case OP_CODE_TAD:
				TAD(&registers);
				strcpy(instruct_text, "TAD");
				opcode_freq[1]++;
				break;
			case OP_CODE_ISZ:
				ISZ(&registers);
				strcpy(instruct_text, "ISZ");
				opcode_freq[2]++;
				break;
			case OP_CODE_DCA:
				DCA(&registers);
				strcpy(instruct_text, "DCA");
				opcode_freq[3]++;
				break;
			case OP_CODE_JMS:
				JMS(&registers);
				strcpy(instruct_text, "JMS");
				opcode_freq[4]++;
				break;
			case OP_CODE_JMP:
				JMP(&registers);
				strcpy(instruct_text, "JMP");
				opcode_freq[5]++;
				break;
			case OP_CODE_IO:
				opcode_freq[6]++;
		
				switch(current_instruction & IO_OPCODE_BITS_MASK) {
				case IO_OPCODE_KCF_BITS:
					KCF(local_kb);
					strcpy(instruct_text, "KCF");
					break;
				case IO_OPCODE_KSF_BITS:
					KSF(&registers, local_kb);
					strcpy(instruct_text, "KSF");
					break;
				case IO_OPCODE_KCC_BITS:
					KCC(&registers, local_kb);
					strcpy(instruct_text, "KCC");
					break;
				case IO_OPCODE_KRS_BITS:
					KRS(&registers, local_kb);
					strcpy(instruct_text, "KRS");
					break;
				case IO_OPCODE_KRB_BITS:
					KRB(&registers, local_kb);
					strcpy(instruct_text, "KRB");
					break;
				case IO_OPCODE_TFL_BITS:
					TFL(&registers);
					strcpy(instruct_text, "TFL");
					break;
				case IO_OPCODE_TSF_BITS:
					TSF(&registers);
					strcpy(instruct_text, "TSF");
					break;
				case IO_OPCODE_TCF_BITS:
					TCF(&registers);
					strcpy(instruct_text, "TCF");
					break;
				case IO_OPCODE_TPC_BITS:
					TPC(&registers);
					strcpy(instruct_text, "TPC");
					break;
				case IO_OPCODE_TLS_BITS:
					TLS(&registers);
					strcpy(instruct_text, "TLS");
					break;
				}
				break;
			case OP_CODE_MICRO:
				opcode_freq[7]++;
				instruct_text[0] = '\0'; // intialize string as empty
				switch(current_instruction & MICRO_INSTRUCTION_GROUP_BIT){
				case 0:	// Group 1
					// Go through the bits and exeucute in sequence if high
					if((current_instruction & MICRO_INSTRUCTION_BITS_MASK) == 0){
						break;	// NOP instruction
					}
					if((current_instruction & MICRO_INSTRUCTION_CLA_BITS) == MICRO_INSTRUCTION_CLA_BITS){
						CLA(&registers);
						strcat(instruct_text, "CLA ");
					}
					if((current_instruction & MICRO_INSTRUCTION_CLL_BITS) == MICRO_INSTRUCTION_CLL_BITS){
						CLL(&registers);
						strcat(instruct_text, "CLL ");
					}
					if((current_instruction & MICRO_INSTRUCTION_CMA_BITS) == MICRO_INSTRUCTION_CMA_BITS){
						CMA(&registers);
						strcat(instruct_text, "CMA ");
					}
					if((current_instruction & MICRO_INSTRUCTION_CML_BITS) == MICRO_INSTRUCTION_CML_BITS){
						CML(&registers);
						strcat(instruct_text, "CML ");
					}
					if((current_instruction & MICRO_INSTRUCTION_IAC_BITS) == MICRO_INSTRUCTION_IAC_BITS){
						IAC(&registers);
						strcat(instruct_text, "IAC ");
					}
					if((current_instruction & MICRO_INSTRUCTION_RAR_BITS) == MICRO_INSTRUCTION_RAR_BITS){
						if((current_instruction & MICRO_INSTRUCTION_RTR_BITS) == MICRO_INSTRUCTION_RTR_BITS){
							RTR(&registers);
							strcat(instruct_text, "RTR ");
						} else {
							RAR(&registers);
							strcat(instruct_text, "RAR ");
						}
					}
					if((current_instruction & MICRO_INSTRUCTION_RAL_BITS) == MICRO_INSTRUCTION_RAL_BITS){
						if((current_instruction & MICRO_INSTRUCTION_RTL_BITS) == MICRO_INSTRUCTION_RTL_BITS){
							RTL(&registers);
							strcat(instruct_text, "RTL ");
						} else {
							RAL(&registers);
							strcat(instruct_text, "RAL ");
						}
					}
					break;

				case MICRO_INSTRUCTION_GROUP_BIT:	// Group 2
		   		//OR subgroup if bit 3 is not set and bits 0-2 are not set
					if( !(current_instruction & MICRO_GROUP2_SUBGROUP_BIT) && !(current_instruction & 07) ) {
						// Set returns to 0 initially
						subgroup_returns[0] = subgroup_returns[1] = subgroup_returns[2] = 0;
						if((current_instruction & MICRO_INSTRUCTION_SMA_BITS) == MICRO_INSTRUCTION_SMA_BITS){
							subgroup_returns[0] = SMA(&registers);
							strcat(instruct_text, "SMA ");
						}
						if((current_instruction & MICRO_INSTRUCTION_SZA_BITS) == MICRO_INSTRUCTION_SZA_BITS){
							subgroup_returns[1] = SZA(&registers);
							strcat(instruct_text, "SZA ");
						}
						if((current_instruction & MICRO_INSTRUCTION_SNL_BITS) == MICRO_INSTRUCTION_SNL_BITS){
							subgroup_returns[2] = SNL(&registers);
							strcat(instruct_text, "SNL ");
						}
						subgroup_taken = 0;
						current_PC = registers.PC;
						//If any in a sequence would skip, then skip
						if(subgroup_returns[0] || subgroup_returns[1] || subgroup_returns[2]) {
							registers.PC++;
							subgroup_taken = 1;
						}
						write_branch_trace(current_PC, current_PC + 1, conditional_text, subgroup_taken);
					}
					//AND subgroup if bit 3 is set and bits 0-2 are not set
					else if( current_instruction & MICRO_GROUP2_SUBGROUP_BIT ) {
						//Set to 1 initially so it passes the AND at the end
						subgroup_returns[0] = 1;
						subgroup_returns[1] = 1;
						subgroup_returns[2] = 1;
					
						if((current_instruction & MICRO_INSTRUCTION_SPA_BITS) == MICRO_INSTRUCTION_SPA_BITS){
							subgroup_returns[0] = SPA(&registers);
							strcat(instruct_text, "SPA ");
						}
						if((current_instruction & MICRO_INSTRUCTION_SNA_BITS) == MICRO_INSTRUCTION_SNA_BITS){
							subgroup_returns[1] = SNA(&registers);
							strcat(instruct_text, "SNA ");
						}
						if((current_instruction & MICRO_INSTRUCTION_SZL_BITS) == MICRO_INSTRUCTION_SZL_BITS){
							subgroup_returns[2] = SZL(&registers);
							strcat(instruct_text, "SZL ");
						}

						subgroup_taken = 0;
						current_PC = registers.PC;
						//If all in sequence are skip, then skip
						if(subgroup_returns[0] && subgroup_returns[1] && subgroup_returns[2]) {
							registers.PC++;
							subgroup_taken = 1;
						}
						write_branch_trace(current_PC, current_PC + 1, conditional_text, subgroup_taken);
					}

					//SKP will run along with SPA, SNA or SZL if bits 3-5 are not checked
					if((current_instruction & 07770) == MICRO_INSTRUCTION_SKP_BITS){
						SKP(&registers);
						strcat(instruct_text, "SKP ");
					}
					if((current_instruction & MICRO_INSTRUCTION_CLA_BITS) == MICRO_INSTRUCTION_CLA_BITS){
						CLA(&registers);
						strcat(instruct_text, "CLA ");
					}
					if((current_instruction & MICRO_INSTRUCTION_OSR_BITS) == MICRO_INSTRUCTION_OSR_BITS){
						OSR(&registers);
						strcat(instruct_text, "OSR ");
					}
					if((current_instruction & MICRO_INSTRUCTION_HLT_BITS) == MICRO_INSTRUCTION_HLT_BITS){
						HLT(local_kb);
						strcat(instruct_text, "HLT ");
						running = 0; // stop further execution
					}
					break;
				}
				break;
			}

#ifdef MEMORY_DEBUG
			switch (addressing_mode){
			case 0:
				printf("Opcode: %u Addressing mode: %u %s\n", registers.IR,0, "Direct Mode, \tZero Page");
				break;
			case 1:
				printf("Opcode: %u Addressing mode: %u %s\n", registers.IR,1, "Direct Mode, \tCurrent Page");
				break;
			case 2:
				printf("Opcode: %u Addressing mode: %u %s\n", registers.IR,2, "Indirect Mode, \tZero Page");
				break;
			case 3:
				printf("Opcode: %u Addressing mode: %u %s\n", registers.IR,3, "Indirect Mode, \tCurrent Page");
				break;
			case 4:
				printf("Opcode: %u Addressing mode: %u %s\n", registers.IR,4, "Indirect Mode, \tAuto Indexing");
				break;
			default:
				break;
			}
#endif

#ifdef DEBUG
			printf("Cycles Before = %u, ", clock_cycles);
#endif

			if(addressing_mode == DIRECT_MODE ||addressing_mode == (DIRECT_MODE +1)  ) {
				clock_cycles += opcode_cycles[registers.IR];
			}
			else if(addressing_mode == INDIRECT_MODE || addressing_mode == (INDIRECT_MODE+1)) {
				clock_cycles += opcode_cycles[registers.IR] + 1;
			}
			else {	/* Autoincrement mode */
				clock_cycles += opcode_cycles[registers.IR] + 2;
			}

			fprintf(opcode_file, "Opcode %s: %03o, AC: %04o, Link: %01o, MB: %04o, PC: %04o, CPMA: %04o\n",
                    instruct_text, registers.IR, registers.AC & CUTOFF_MASK, 
					registers.link_bit, registers.MB & CUTOFF_MASK, registers.PC, registers.CPMA);

		} // while(running)
		if (debugger_running()){
			debugger_post_program_run();
		}
	} // while (debugger_running()) 

    fclose(opcode_file);
	
	pthread_exit(0);
} // end run_program

void init_system(int argc, char* argv[]) {
	int i;
	int branch_trace_open;

	branch_trace_open = branch_trace_init();

	if(branch_trace_open) exit(branch_trace_open);

	mem_init();
	fill_memory(argc, argv);
	debugger_init(argc, argv);

	for(i = 0; i < OPCODE_NUM; i++) {
		opcode_freq[i] = 0;
	}

	opcode_text[0] = "AND";
	opcode_text[1] = "TAD";
	opcode_text[2] = "ISZ";
	opcode_text[3] = "DCA";
	opcode_text[4] = "JMS";
	opcode_text[5] = "JMP";
	opcode_text[6] = "I\\O";
	opcode_text[7] = "Micro Ops";
}

/******************************************************************************
** FILLS MEMORY WITH INPUTTED MEMORY FILE
@CHANGELOG:
	JSP:
	-Modified argv count and first 'if' statement to take tracefile arg
	-Added tracefile generation functions
******************************************************************************/
void fill_memory(int argc, char* argv[]) {
	const uint8_t data_mask = 0x3F;		/* Keep lower 6 bits of the upper/lower bytes */
	const uint8_t address_mask = 0x40;	/* Mask to check the address bit */
	const uint8_t high_shift	= 6;		/* Shifts the high byte */
	FILE* program_file;
	uint16_t high_byte, low_byte, word_value;
	static uint16_t address = 0;

	int return1, return2;
	return1 = return2 = 0;

	if(argc == 3 || argc == 4) {
		program_file = fopen(argv[1], "r");
		trace_name = argv[2];
	}
	else {
		printf("Please provide a valid program filename to use with the simulator.\n");
		printf("FORMAT:\n PDP_sim <input_file> <trace_file>\n");
		exit(-1);
	}
	if(program_file == NULL) {
		printf("The entered program filename does not exist.\n");
		exit(-2);
	}

	/* Main loop that loads the memory */
	for(;;) {
		/* Grab up to a maximum of three octal values */
		return1 = fscanf(program_file, "%3" SCNo16, &high_byte);
		return2 = fscanf(program_file, "%3" SCNo16, &low_byte);
	
		if(return1 == EOF || return2 == EOF)
			break;

		word_value = ((high_byte & data_mask) << high_shift) | (low_byte & data_mask);

		#ifdef FILL_DEBUG
			printf("From file - high: %o, low: %o\n", high_byte, low_byte);
			printf("Word_value: %o\n", word_value);
		#endif

		if(high_byte & address_mask) {
			address = word_value;
			#ifdef FILL_DEBUG
				printf("Address changed to: %o\n", address);
			#endif
		}
		else {		
			memory[address] = word_value | MEMORY_VALID_BIT;
			#ifdef FILL_DEBUG
				printf("Memory value at address %o set to: %o\n", address, memory[address]);
			#endif
			address++;
		}

		#ifdef FILL_DEBUG
			printf("\n");
		#endif
	}/*end for*/

	fclose(program_file);
}

void print_stats(void) {
	int i;
	uint32_t executed_total = 0;

	printf("*************************************************************\n");
	printf("***********************PRINTING STATS************************\n");
	printf("*************************************************************\n");
	printf("Total clock cycles = %u\n", clock_cycles);
	
	for(i = 0; i < OPCODE_NUM; i++) {
		printf("%s was executed %u times\n", opcode_text[i], opcode_freq[i]);
		executed_total += opcode_freq[i];
	}

	printf("The total number of opcodes executed = %u\n", executed_total);
}

/******************************************************************************
**	EOF
******************************************************************************/
