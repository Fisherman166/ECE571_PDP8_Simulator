/******************************************************************************
** ECE486/586 PDP-8 Simulator
** Sean Koppenhafer, Luis Santiago, Ken Benderly
**
** main.h
*/

#ifndef MAIN_H
#define MAIN_H

//#define FILL_DEBUG
//#define DEBUG

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define OPCODE_NUM 8

int main(int argc, char* argv[]);
void* run_program(void*);
void init_system(int argc, char* argv[]);
void fill_memory(int argc, char* argv[]);	/* Fills memory at bootup */
void print_stats(void);

#endif
