#include "tbxbindings.h"
#include "svdpi.h"
#include <stdio.h>
#include <inttypes.h>
#include <stdlib.h>
#include <string.h>

#define WORD_MASK 07777
#define MEM_SIZE 4096
//#define FILL_DEBUG

FILE* init_mem_file;
FILE* opcode_file;
FILE* branch_trace_file;
FILE* valid_memory_file;
FILE* memory_trace_file;

//For temp memory 
typedef struct {
    uint16_t address;
    uint16_t data;
} memory_cell;
static memory_cell temp_memory[MEM_SIZE];
static uint16_t max_index = 0;

// Function prototypes
int init_tracefiles();
int init_temp_mem();
int send_word_to_hdl(svBitVecVal*, svBitVecVal*, svBitVecVal*);
int write_mem_trace(const svLogicVecVal*, const svLogicVecVal*, 
                    const svLogicVecVal*, const svLogicVecVal*);
int write_branch_trace(const svLogicVecVal*, const svLogicVecVal*,
                       const svBitVecVal*, const svBit*);
int close_tracefiles();

//*******************************Start of functions*******************************
//
int init_tracefiles() {
    const char* opcode_filename = "opcodes_sv.txt";
    const char* branch_trace_filename = "branch_trace_sv.txt";
    const char* valid_memory_filename = "valid_memory_sv.txt";
    const char* memory_trace_filename = "memory_trace_sv.txt";

    opcode_file = fopen(opcode_filename, "w");
    branch_trace_file = fopen(branch_trace_filename, "w");
    valid_memory_file = fopen(valid_memory_filename, "w");
    memory_trace_file = fopen(memory_trace_filename, "w");

    if(opcode_file == NULL) {
        printf("Opcode file %s failed to open\n", opcode_filename);
        exit(-1);
    }
    if(branch_trace_file == NULL) {
        printf("Branch trace file %s failed to open\n", branch_trace_filename);
        exit(-2);
    }
    if(valid_memory_file == NULL) {
        printf("Valid memory file %s failed to open\n", valid_memory_filename);
        exit(-3);
    }
    if(memory_trace_file == NULL) {
        printf("Memory trace file %s failed to open\n", memory_trace_filename);
        exit(-4);
    }

    fprintf(memory_trace_file, "OP Addr Bus  Mem \n");
    fprintf(memory_trace_file, "-- ---- ---- ----\n");
    printf("Done opening trace files\n");

    return 0;
}

int init_temp_mem() {
    const char* init_mem_filename = "init_mem.obj";
    const uint8_t data_mask = 0x3F;
    const uint8_t address_mask = 0x40;
    const uint8_t high_shift = 6;
    uint16_t address = 0;
    int return1, return2;
    uint32_t high_byte, low_byte;
    uint16_t word_value;

    init_mem_file = fopen(init_mem_filename, "r");
    if(init_mem_file == NULL) {
        printf("Failed to open init file %s\n", init_mem_file);
        exit(-5);
    }
    printf("Opened init memory sucessfully\n");

    for(;;) {
        return1 = fscanf(init_mem_file, "%o", &high_byte);
        return2 = fscanf(init_mem_file, "%o", &low_byte);

        if(return1 == EOF || return2 == EOF) break;
        word_value = ((high_byte & data_mask) << high_shift) | (low_byte & data_mask);

        #ifdef FILL_DEBUG
            printf("From file - high %o, low: %o\n", high_byte, low_byte);
            printf("Word value: %o\n", word_value);
        #endif

        if(high_byte & address_mask) {
            address = word_value;
            #ifdef FILL_DEBUG
                printf("Address changed to: %o\n", address);
            #endif
        }
        else {
            temp_memory[max_index].address = address;
            temp_memory[max_index].data = word_value;
            address++;
            max_index++;
            #ifdef FILL_DEBUG
                printf("Memory value at address %o set to: %o\n", temp_memory[max_index-1].address, temp_memory[max_index-1].data);
            #endif
        }
    }
    printf("Done filling temp memory\n");

    fclose(init_mem_file);
    return 0;
}

// Asserts done when all memory locations have been written to in memory
int send_word_to_hdl(svBitVecVal* mem_address, svBitVecVal* mem_data, svBit* mem_done) {
    static uint16_t mem_index = 0;

    if(mem_index == max_index){
        *mem_done = 1;
        printf("Done sending words from temp memory to memory\n");
    }
    else {
        *mem_done = 0;
        *mem_address = temp_memory[mem_index].address & WORD_MASK;
        *mem_data = temp_memory[mem_index].data & WORD_MASK;
        mem_index++;
    }

    return 0;
}

int write_mem_trace(const svLogicVecVal* mem_type, const svLogicVecVal* address, 
                    const svLogicVecVal* data_bus, const svLogicVecVal* data_mem) {
    const uint8_t DR_value = 0;
    const uint8_t IF_value = 1;
    const uint8_t DW_value = 2;
    char mem_type_text[3];

    if(mem_type->bval) {
        printf("MEM_TRACE ERROR: mem_type is X or Z\n");
        exit(-6);
    }
    if(address->bval) {
        printf("MEM_TRACE ERROR: address is X or Z\n");
        exit(-7);
    }
    if(data_bus->bval) {
        printf("MEM_TRACE ERROR: data_bus is X or Z\n");
        exit(-8);
    }
    if(data_mem->bval) {
        printf("MEM_TRACE ERROR: data_mem is X or Z\n");
        exit(-9);
    }

    if(mem_type->aval == DR_value) strcpy(mem_type_text, "DR");
    else if(mem_type->aval == IF_value) strcpy(mem_type_text, "IF");
    else if(mem_type->aval == DW_value) strcpy(mem_type_text, "DW");
    else strcpy(mem_type_text, "NA");

    fprintf(memory_trace_file, "%s %04o %04o %04o\n", mem_type_text, 
            address->aval, data_bus->aval, data_mem->aval);
    return 0;
}

int write_branch_trace(const svLogicVecVal* current_pc, const svLogicVecVal* target_pc,
                       const svBitVecVal* branch_type, const svBit* taken) {
    const uint8_t type_unconditional = 0;
    const uint8_t type_conditional = 1;
    const uint8_t type_subroutine = 2;
    const uint8_t taken_no = 0;
    char branch_type[15];
    char taken_text[10];

    if(current_pc->bval) {
        printf("BRANCH TRACE ERROR: current_pc is X or Z\n");
        exit(-10);
    }
    if(target_pc->bval) {
        printf("BRANCH TRACE ERROR: target_pc is X or Z\n");
        exit(-11);
    }

    if(*branch_type == type_unconditional) strcpy(branch_type, "Unconditional");
    else if(*branch_type == type_conditional) strcpy(branch_type, "Conditional");
    else if(*branch_type == type_subroutine) strcpy(branch_type, "Subroutine");
    else strcpy(branch_type, "Error");

    if(*taken == taken_no) strcpy(taken_text, "Not Taken");
    else strcpy(taken_text, "Taken");

    fprintf(branch_trace_file, "Current PC: %04o, Target: %04o, Type: %s, Result: %s\n",
            current_pc->aval, target_pc->aval, branch_type, taken_text);

    return 0;
}
    
int close_tracefiles() {
    fclose(opcode_file);
    fclose(branch_trace_file);
    fclose(valid_memory_file);
    fclose(memory_trace_file);

    return 0;
}

