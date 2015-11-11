// debugger.h

#ifndef _DEBUGGER_H
#define _DEBUGGER_H

#include "cpu.h"

void debugger_init(int argc, char* argv[]);
void debugger_post_program_run(void);
void debugger_pre_instruction_fetch(regs *registers);
unsigned int debugger_running(void);

#endif
