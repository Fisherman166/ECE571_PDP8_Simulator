CC=gcc
CFLAGS= -g -std=c99 -c -Wall
LDFLAGS= -pthread
SOURCES=main.c memory.c cpu.c kb_input.c branch_trace.c debugger.c
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=PDP8_sim

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) $(LDFLAGS) $(OBJECTS) -o $@

.c.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -rf *~ *.o *.txt $(EXECUTABLE)

# to generate this list use: gcc -MM -g -c -Wall *.c

branch_trace.o: branch_trace.c branch_trace.h
cpu.o: cpu.c cpu.h kb_input.h memory.h branch_trace.h
debugger.o: debugger.c debugger.h cpu.h
kb_input.o: kb_input.c kb_input.h
main.o: main.c main.h memory.h cpu.h kb_input.h branch_trace.h debugger.h
memory.o: memory.c memory.h cpu.h kb_input.h
