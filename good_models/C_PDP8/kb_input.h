/******************************************************************************
** ECE486/586 PDP-8 Simulator
** Sean Koppenhafer, Luis Santiago, Ken Benderly, J.S. Peirce
** 
** 21 JANUARY 2015
** MEMORY.C 	IMPLEMENTATION FILE FOR MEMORY OP FUNCTIONS
******************************************************************************/

#ifndef KB_INPUT_H
#define KB_INPUT_H

#include <stdio.h>
#include <unistd.h>
#include <termios.h>
#include <sys/select.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdint.h>

#define NB_ENABLE 1
#define NB_DISABLE 0

pthread_mutex_t keyboard_mux;

struct keyboard {
   char input_char;
   uint8_t input_flag;	//0 = no input, 1 = input
   uint8_t quit;
};

void* read_keyboard(void*);
int kbhit(void);
void nonblocking(int);

#endif

