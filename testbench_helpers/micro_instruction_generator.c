#include <stdio.h>
#include <inttypes.h>
#include <unistd.h>

#define I_REG_MASK 0x1FF
#define AC_REG_MASK 0xFFF
#define SINGLE_BIT 0x1o

// Group 1 micro instructions
#define NOP  07000
#define CLA  07200
#define CLL  07100
#define CMA  07040
#define CML  07020
#define IAC  07001
#define RAR  07010
#define RTR  07012
#define RAL  07004
#define RTL  07006

// Group 2 micro instructions
#define SMA  07100
#define SZA  07040
#define SNL  07020
#define SPA  07110
#define SNA  07050
#define SZL  07030
#define SKP  07010
#define CLA  07200
#define OSR  07004
#define HLT  07002

struct {
    uint16_t i_reg;
    uint16_t ac_reg;
    uint8_t l_reg;
    uint16_t result_ac;
    uint8_t result_link;
    uint8_t ;
    uint8_t ;


int main() {
    FILE *output_file = fopen("micro_instructions.txt", w);
    
    if(output_file == NULL) {
        printf("Failed to open output file\n");
        exit(-1);
    }

    
        
