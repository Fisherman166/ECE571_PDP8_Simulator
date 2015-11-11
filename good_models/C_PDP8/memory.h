/******************************************************************************
** ECE486/586 PDP-8 Simulator
** Sean Koppenhafer, Luis Santiago, Ken, J.S. Peirce
** 
** 15 JANUARY 2015
** memory.h
@CHANGELOG:
	JSP:
	-added tracefile open/close functions
	-TODO: talk to Luis about args passed for mem read/writes
******************************************************************************/
#include <inttypes.h>
#include <unistd.h>
#include <stdio.h>
#include "cpu.h"	//Needed for regs

#ifndef MEMORY_H
#define MEMORY_H

/* Total memory size is 4K */
#define WORDS_PER_PAGE 128
#define PAGES 32

#define MEMORY_MASK				0xFFF	/*Only 12 bits needed for address or a data*/
#define MEMORY_VALID_BIT 		0x8000
#define MEMORY_BREAKPOINT_BIT	0x4000
#define MEMORY_TRACE_BIT		0x2000

/* For trace files */
#define DATA_READ 0
#define INSTRUCTION_FETCH 1

/* Addressing mode defines */
#define DIRECT_MODE 0
#define INDIRECT_MODE 2
#define AUTOINCREMENT_MODE 4

/* Effective address */
#define PageMode(var) 	((var) & (1<<7))
#define AddrMode(var) 	((var) & (1<<8))
#define OFFSET_MASK   	0X7F
#define PAGE_MASK	0XF80

uint16_t memory[PAGES * WORDS_PER_PAGE];
char *trace_name;
FILE *trace_file;
FILE *b_points;

// Prototypes
void mem_init(void);
void mem_print_valid(void);
int trace_init();
int trace_close();
uint16_t mem_read(uint16_t to_convert, uint8_t read_or_fetch);
void mem_write(uint16_t to_convert, uint16_t data);
uint16_t zeropage(uint16_t);
uint16_t currentpage(uint16_t, regs*);
//uint16_t getaddress(uint16_t, regs*);
uint8_t EffAddCalc(uint16_t, regs*);
void set_breakpoint(uint16_t);
void remove_breakpoint(uint16_t);
void print_breakpoints(uint16_t *, char *);
/******************************************************************************
**	EOF
******************************************************************************/
#endif

