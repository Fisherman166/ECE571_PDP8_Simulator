/******************************************************************************
** ECE486/586 PDP-8 Simulator
** Sean Koppenhafer, Luis Santiago, Ken Benderly, J.S. Peirce
** 
** 21 JANUARY 2015
** MEMORY.C 	IMPLEMENTATION FILE FOR MEMORY OP FUNCTIONS
******************************************************************************/
#include "memory.h"

/******************************************************************************
** 	READ FROM MEMORY
**	FOR READ_OR_FETCH VARIABLE: 0 = DATA READ		1 = INSTRUCTION_FETCH
******************************************************************************/
uint16_t mem_read(uint16_t to_convert, uint8_t read_or_fetch){
	uint16_t converted;
	uint16_t retval;

    converted = to_convert & CUTOFF_MASK;

	//Print to trace file and handle the fetch accordingly
	if(read_or_fetch == DATA_READ) {
		//Remove internal state bits for read
		retval = memory[converted] & CUTOFF_MASK;
		fprintf( trace_file, "DR %04o %04o %04o\n", converted, retval, memory[converted] & CUTOFF_MASK);
	}
	else if(read_or_fetch == INSTRUCTION_FETCH) {
		retval = memory[converted] & CUTOFF_MASK;
		fprintf( trace_file, "IF %04o %04o %04o\n", converted, retval, memory[converted] & CUTOFF_MASK);
	}
	else {
		fprintf( trace_file, "Read type not recognized\n");
	}

	return retval;
}/*end mem_read()*/

/******************************************************************************
** 	WRITE TO MEMORY 	
******************************************************************************/
void mem_write(uint16_t to_convert, uint16_t data){
	uint16_t converted;
    converted = to_convert & CUTOFF_MASK;

	//Make sure to make the location in memory valid
	if(memory[converted] & MEMORY_BREAKPOINT_BIT) {
		memory[converted] = MEMORY_VALID_BIT | data | MEMORY_BREAKPOINT_BIT;
	}
	else {
		memory[converted] = MEMORY_VALID_BIT | data;
	}	

	fprintf(trace_file, "DW %04o %04o %04o\n", converted, data & CUTOFF_MASK, memory[converted] & CUTOFF_MASK);
	#ifdef MEMORY_DEBUG
		printf("CALLEE->WROTE: %o to: %o IN OCTAL\n", data, converted);
		printf("CALLEE->WROTE: %u to: %u IN UNSIGNED DEC\n", data, converted);
	#endif
}/*end mem_write*/

/******************************************************************************
** 	INITIALIZE THE MEMORY 	
******************************************************************************/
void mem_init(void){
	unsigned int i;

	for(i=0; i < PAGES * WORDS_PER_PAGE; i++){
		memory[i] &= ~(MEMORY_VALID_BIT | MEMORY_BREAKPOINT_BIT); // clear valid and breakpoint bits
	}	
} // end mem_init

/******************************************************************************
** 	PRINT ALL VALID MEMORY LOCATIONS	
******************************************************************************/
void mem_print_valid(void){
	unsigned int i;
    FILE* valid_memory_file = fopen("valid_memory_golden.txt", "w");

    if(valid_memory_file == NULL) {
        printf("Failed to open valid memory file\n");
        exit(-10);
    }

	fprintf(valid_memory_file, "Address    Contents\n");
	fprintf(valid_memory_file, "-------    --------\n");
	for(i=0; i < PAGES * WORDS_PER_PAGE; i++){
		if (memory[i] & MEMORY_VALID_BIT){
			fprintf(valid_memory_file, "%04o        %04o\n", i, memory[i] & MEMORY_MASK);
		}
	}
   fclose(valid_memory_file);
} // end mem_print_valid

/******************************************************************************
**	OPEN THE TRACEFILE TO APPEND, START AT BEGINNING OF FILE: "a+"
******************************************************************************/
int trace_init(){
	int ret_val;
	trace_file = fopen(trace_name, "w");
	
	if(trace_file == NULL){
	#ifdef TRACE_DEBUG
		printf("ERROR: Unable to open memory trace file: %s\n", trace_name);
	#endif
		ret_val = -1;
	}/*end if*/
	else{
	#ifdef TRACE_DEBUG
		printf("Memory trace file: %s opened successfully\n", trace_name);
	#endif
		ret_val=0;
	}/*end else*/

   fprintf(trace_file, "OP Addr Bus  Mem \n");
   fprintf(trace_file, "-- ---- ---- ----\n");
return ret_val;
}/*end trace_init()*/

/******************************************************************************
** CALL THIS FUNCTION AT COMPLETION OF PROGRAM TO CLOSE TRACEFILE
** TODO: MAY NOT BE A BAD IDEA TO OPEN/CLOSE EACH TIME WE WRITE OUT?
******************************************************************************/
int trace_close(){
	int ret_val;
	ret_val = fclose(trace_file);
return ret_val;
}/*end close_trace()*/

/******************************************************************************
**	RETURN EFFECTIVE ADDRESS AT ZERO PAGE
******************************************************************************/
uint16_t zeropage (uint16_t instruction)
{
    return instruction & OFFSET_MASK;
}

/******************************************************************************
**	RETURN EFFECTVE ADDRESS AT THE CURRENT PAGE
******************************************************************************/
uint16_t currentpage (uint16_t instruction, regs* reg)
{
    return ( (reg->PC & PAGE_MASK) | (instruction & OFFSET_MASK) );
}

/******************************************************************************
**	DECODE ADDRESS
******************************************************************************/
// Check bit 4 (on PDP8 )  to determine current page or zero page mode

uint16_t getaddress(uint16_t instruction,regs* reg, uint8_t * page)
{
	uint16_t retval;
	if (PageMode(instruction)) // current page
   {
   	retval = currentpage(instruction, reg);
  	*page=1;
   }
   else
   {// zero page
   	retval = zeropage(instruction);
	*page=0;
   }

	return retval;
}

/******************************************************************************
**	CALCULATE THE EFFECTIVE ADDRESS
**	RETURNS 0 FOR DIRECT ADDRESSING, 2 FOR INDIRECT ADDRESSING,
** AND 4 FOR AUTOINCREMENT
******************************************************************************/
uint8_t EffAddCalc(uint16_t instruction, regs* reg)
{
	uint16_t ptr_address, indirect_address;
	uint8_t addressing_mode, page_mode;

page_mode =0;
    if(AddrMode(instruction))
    {
        /* Indirect mode
         gets the ponter address*/
	ptr_address = getaddress(instruction, reg, & page_mode);
        indirect_address = mem_read(ptr_address, DATA_READ);
	
	addressing_mode = INDIRECT_MODE+ page_mode;
        
        // check if address is the range of auto indexing
        if (ptr_address >= 010 && ptr_address <= 017)
        {
            addressing_mode = AUTOINCREMENT_MODE;
            ++indirect_address;
            mem_write(ptr_address, indirect_address );
            
        }
        
        reg->CPMA= indirect_address;
    }
    else
    {
        // not indirect just store the value
        reg->CPMA = getaddress(instruction, reg,& page_mode);
		  addressing_mode = DIRECT_MODE + page_mode;
    }

	 return addressing_mode;
}

/******************************************************************************
**	SETS A BREAKPOINT IN MEMORY
******************************************************************************/
void set_breakpoint(uint16_t breakpoint_address) {
	memory[breakpoint_address] |= MEMORY_BREAKPOINT_BIT;
	printf("BOO = %X\n", memory[breakpoint_address]);
}

/******************************************************************************
**	REMOVES A BREAKPOINT IN MEMORY
******************************************************************************/
void remove_breakpoint(uint16_t breakpoint_address) {
	memory[breakpoint_address] &= ~MEMORY_BREAKPOINT_BIT;
}

/******************************************************************************
 * 	PRINT BREAKPOINTS
 * 	TODO: MOVE THIS TO MEMORY.C?
 *****************************************************************************/
void print_breakpoints(uint16_t *memory, char *breakpoint_file){
	//FILE * b_points;	//declare locally or in memory.h?
	int index=0;
	//open file
	b_points = fopen(breakpoint_file, "w");
			
	if(b_points==NULL){
	#ifdef DEBUG
		printf("File open error, does it exist?\n");
	#endif
	}else{
	#ifdef DEBUG
		printf("File opened successfully!\n");
	#endif
	//walk memory 	
		for(index = 0; index<(PAGES*WORDS_PER_PAGE); index++){
			//if BREAKPOINT bit set, write to file
			if((memory[index] & MEMORY_BREAKPOINT_BIT)){
				fprintf(b_points, "%o,", memory[index]);
			#ifdef DEBUG
				printf("Wrote: %u to: %s\n", memory[index], breakpoint_file);
			#endif
			}//end if
		}//end for
	//close file
	fclose(b_points);
	}//end else
}//end print_breakpoints
/******************************************************************************
 * 	EOF
 *****************************************************************************/
