CC=gcc
CFLAGS= -c -Wall
SOURCES=micro_instruction_generator.c
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=micro_instruction_generator

all: $(SOURCES) $(EXECUTABLE)

$(EXECUTABLE): $(OBJECTS)
	$(CC) -D GROUP1_TESTS -D GROUP2_TESTS -D GROUP3_TESTS -D RUN_SINGLE_TESTS -D RUN_EXHAUSTIVE_TESTS -D RUN_DIRECTED_TESTS $(OBJECTS) -o $@

.c.o:
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -rf *~ *.o *.txt $(EXECUTABLE)

# to generate this list use: gcc -MM -g -c -Wall *.c

micro_instruction_generator.o: micro_instruction_generator.c micro_instruction_generator.h
