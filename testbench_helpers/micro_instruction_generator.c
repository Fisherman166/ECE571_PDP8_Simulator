#include "micro_instruction_generator.h"

int main() {
    FILE *output_file = fopen("../test_cases/micro_instructions.txt", "w");
    regs registers;
    
    if(output_file == NULL) {
        printf("Failed to open output file\n");
        exit(-1);
    }
    
    #ifdef RUN_SINGLE_TESTS
        group1_single_tests(&registers, output_file);
    #endif

    #ifndef RUN_SINGLE_TESTS
        group1_exhaustive_tests(&registers, output_file);
    #endif

    fclose(output_file);
    return 0;
}

// Uses function pointer so you can pass in any opcode
void run_exhaustive_test(void (*opcode) (regs*, uint16_t, uint8_t), regs* registers, FILE* output_file) {
    uint16_t i;

    for(i = 0; i < 010000; i++) {
        opcode(registers, i, 0);
        write_regs(registers, output_file);
        opcode(registers, i, 1);
        write_regs(registers, output_file);
    }
}

// Just to sanity check that all of the opcodes work right
void run_single_test(void (*opcode) (regs*, uint16_t, uint8_t), regs* registers, uint16_t ac, FILE* output_file) {
    opcode(registers, ac, 0);
    write_regs(registers, output_file);
    opcode(registers, ac, 1);
    write_regs(registers, output_file);
}

void write_regs(regs* registers, FILE* output_file) {
    fprintf(output_file, "%03o %04o %01u %04o %01u %01u %01u %01u %01u\n", 
            registers->i_reg & I_REG_MASK,
            registers->ac_reg & AC_REG_MASK,
            registers->l_reg & SINGLE_BIT,
            registers->result_ac & AC_REG_MASK,
            registers->result_link & SINGLE_BIT,
            registers->skip & SINGLE_BIT,
            registers->micro_g1 & SINGLE_BIT,
            registers->micro_g2 & SINGLE_BIT,
            registers->micro_g3 & SINGLE_BIT);
}

void group1_single_tests(regs* registers, FILE* output_file) {
    run_single_test(CLA, registers, 07654, output_file);
    run_single_test(CLL, registers, 07654, output_file);
    run_single_test(CMA, registers, 00000, output_file);
    run_single_test(CML, registers, 07654, output_file);
    run_single_test(IAC, registers, 07776, output_file);
    run_single_test(RAR, registers, 07777, output_file);
    //run_single_test(RTR, registers, 07777, output_file); FIXME
    run_single_test(RAL, registers, 07777, output_file);
    //run_single_test(RTL, registers, 07777, output_file); FIXME
}

void group1_exhaustive_tests(regs* registers, FILE* output_file) {
    run_exhaustive_test(CLA, registers, output_file);
    run_exhaustive_test(CLA, registers, output_file);
    run_exhaustive_test(CLL, registers, output_file);
    run_exhaustive_test(CMA, registers, output_file);
    run_exhaustive_test(CML, registers, output_file);
    run_exhaustive_test(IAC, registers, output_file);
    run_exhaustive_test(RAR, registers, output_file);
    //run_exhaustive_test(RTR, registers, output_file); FIXME
    run_exhaustive_test(RAL, registers, output_file);
    //run_exhaustive_test(RTL, registers, output_file); FIXME
}

/* Opcode 7 - group 1 */
void CLA(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0200;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = 00000;
    registers->result_link = link;
    registers->skip = 0;
    registers->micro_g1 = 1;
    registers->micro_g2 = 0;
    registers->micro_g3 = 0;
}

void CLL(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0100;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ac;
    registers->result_link = 0;
    registers->skip = 0;
    registers->micro_g1 = 1;
    registers->micro_g2 = 0;
    registers->micro_g3 = 0;
}

void CMA(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0040;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ~ac;
    registers->result_link = link;
    registers->skip = 0;
    registers->micro_g1 = 1;
    registers->micro_g2 = 0;
    registers->micro_g3 = 0;
}

void CML(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0020;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ac;
    registers->result_link = ~link;
    registers->skip = 0;
    registers->micro_g1 = 1;
    registers->micro_g2 = 0;
    registers->micro_g3 = 0;
}

void IAC(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0001;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = (ac + 1);
    registers->result_link = link;
    registers->skip = 0;
    registers->micro_g1 = 1;
    registers->micro_g2 = 0;
    registers->micro_g3 = 0;
}

void RAR(regs* registers, uint16_t ac, uint8_t link) {
    const uint8_t bit11_shift = 11;

    registers->i_reg = 0010;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = (ac >> 1) | (link << bit11_shift);
    registers->result_link = registers->result_ac & 1;
    registers->skip = 0;
    registers->micro_g1 = 1;
    registers->micro_g2 = 0;
    registers->micro_g3 = 0;
}

//FIXME: Does not work as expected
//Doing two RAR in a row and then resetting the inputs to the right value
void RTR(regs* registers, uint16_t ac, uint8_t link) {
    RAR(registers, ac, link);
    RAR(registers, registers->ac_reg, link);

    registers->i_reg = 0012;
    registers->ac_reg = ac;
    registers->l_reg = link;
}

void RAL(regs* registers, uint16_t ac, uint8_t link) {
    const uint8_t shift_num = 12;   /* Shift bit 12 into bit 0 */
    const uint16_t new_link_pos = 0x1000;   /* Bit 12 */

    registers->i_reg = 0004;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = (ac << 1) | link;
    registers->result_link = (registers->result_ac & new_link_pos) >> shift_num;
    registers->skip = 0;
    registers->micro_g1 = 1;
    registers->micro_g2 = 0;
    registers->micro_g3 = 0;
}

//FIXME: Does not work as expected
//Doing two RAL in a row and then resetting the inputs to the right value
void RTL(regs* registers, uint16_t ac, uint8_t link) {
    RAL(registers, ac, link);
    RAL(registers, registers->ac_reg, registers->l_reg);

    registers->i_reg = 0006;
    registers->ac_reg = ac;
    registers->l_reg = link;
}


/* Opcode 7 - group 2 */
void SMA(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0500;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ac;
    registers->result_link = link;
    if(ac & 04000) registers->skip = 1;
    else registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 1;
    registers->micro_g3 = 0;
}

void SZA(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0440;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ac;
    registers->result_link = link;
    if(!ac) registers->skip = 1;
    else registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 1;
    registers->micro_g3 = 0;
}

void SNL(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0420;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ac;
    registers->result_link = link;
    if(link) registers->skip = 1;
    else registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 1;
    registers->micro_g3 = 0;
}

void SPA(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0510;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ac;
    registers->result_link = link;
    if(!(ac & 04000)) registers->skip = 1;
    else registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 1;
    registers->micro_g3 = 0;
}

void SNA(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0450;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ac;
    registers->result_link = link;
    if(ac) registers->skip = 1;
    else registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 1;
    registers->micro_g3 = 0;
}

void SZL(regs* registers, uint16_t ac, uint8_t link) { 
    registers->i_reg = 0430;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ac;
    registers->result_link = link;
    if(!link) registers->skip = 1;
    else registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 1;
    registers->micro_g3 = 0;
}


void MQL(regs* registers, uint16_t ac, uint8_t link) {
    registers->i_reg = 0421;
    registers->ac_reg = ac;
    registers->l_reg = link;
    registers->result_ac = ac;
    registers->result_link = link;
    registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 0;
    registers->micro_g3 = 1;
}

