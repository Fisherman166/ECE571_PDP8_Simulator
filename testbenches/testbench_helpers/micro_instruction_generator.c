#include "micro_instruction_generator.h"

int main() {
    FILE *output_file = fopen("../test_cases/micro_instructions.txt", "w");
    regs registers;
    
    if(output_file == NULL) {
        printf("Failed to open output file\n");
        exit(-1);
    }

    #ifdef GROUP1_TESTS
        #ifdef RUN_SINGLE_TESTS
        group1_single_tests(&registers, output_file);
        #endif
        #ifdef RUN_EXHAUSTIVE_TESTS
        group1_exhaustive_tests(&registers, output_file);
        #endif
        #ifdef RUN_DIRECTED_TESTS
        group1_directed_tests(&registers, output_file);
        #endif
    #endif

    #ifdef GROUP2_TESTS
        #ifdef RUN_SINGLE_TESTS
        group2_single_tests(&registers, output_file);
        #endif
        #ifdef RUN_EXHAUSTIVE_TESTS
        group2_exhaustive_tests(&registers, output_file);
        #endif
        #ifdef RUN_DIRECTED_TESTS
        group2_or_directed_tests(&registers, output_file);
        group2_and_directed_tests(&registers, output_file);
        #endif
    #endif
    
    #ifdef GROUP3_TESTS
       group3_tests(&registers, output_file); 
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
    fprintf(output_file, "%03o %04o %01u %04o %01u %01u %01u %01u %01u %s\n", 
            registers->i_reg & I_REG_MASK,
            registers->ac_reg & AC_REG_MASK,
            registers->l_reg & SINGLE_BIT,
            registers->result_ac & AC_REG_MASK,
            registers->result_link & SINGLE_BIT,
            registers->skip & SINGLE_BIT,
            registers->micro_g1 & SINGLE_BIT,
            registers->micro_g2 & SINGLE_BIT,
            registers->micro_g3 & SINGLE_BIT,
            registers->opcodes);
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

void group1_directed_tests(regs* registers, FILE* output_file) {
    //After setting them on the first bloock, variables after result_link
    //never change
    registers->i_reg = 0300;
    registers->ac_reg = 07777;
    registers->l_reg = 01;
    registers->result_ac = 00000;
    registers->result_link = 00;
    registers->skip = 0;
    registers->micro_g1 = 1;
    registers->micro_g2 = 0;
    registers->micro_g3 = 0;
    strncpy(registers->opcodes, "CLA,CLL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0240;
    registers->ac_reg = 07777;
    registers->l_reg = 01;
    registers->result_ac = 07777;
    registers->result_link = 01;
    strncpy(registers->opcodes, "CLA,CMA", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0120;
    registers->ac_reg = 07777;
    registers->l_reg = 01;
    registers->result_ac = 07777;
    registers->result_link = 01;
    strncpy(registers->opcodes, "CLL,CML", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0205;
    registers->ac_reg = 07777;
    registers->l_reg = 00;
    registers->result_ac = 02;
    registers->result_link = 00;
    strncpy(registers->opcodes, "CLA,IAC,RAL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0375;
    registers->ac_reg = 07777;
    registers->l_reg = 01;
    registers->result_ac = 00000;
    registers->result_link = 00;
    strncpy(registers->opcodes, "CLA,CLL,CMA,CML,IAC,RAR,RAL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);
}

void group2_single_tests(regs* registers, FILE* output_file) {
    run_single_test(SMA, registers, 04001, output_file);    //Skip
    run_single_test(SMA, registers, 00001, output_file);    //Don't skip
    run_single_test(SZA, registers, 00000, output_file);    //Skip
    run_single_test(SZA, registers, 00001, output_file);    //Don't skip
    run_single_test(SNL, registers, 00000, output_file);    //Both skip and no skip

    run_single_test(SPA, registers, 00001, output_file);    //Skip
    run_single_test(SPA, registers, 04001, output_file);    //Don't skip
    run_single_test(SNA, registers, 00004, output_file);    //Skip
    run_single_test(SNA, registers, 00000, output_file);    //Don't skip
    run_single_test(SZL, registers, 00000, output_file);    //Both skip and no skip
}

void group2_exhaustive_tests(regs* registers, FILE* output_file) {
    run_exhaustive_test(SMA, registers, output_file);
    run_exhaustive_test(SZA, registers, output_file);
    run_exhaustive_test(SNL, registers, output_file);
    run_exhaustive_test(SPA, registers, output_file);
    run_exhaustive_test(SNA, registers, output_file);
    run_exhaustive_test(SZL, registers, output_file);
}

void group2_or_directed_tests(regs* registers, FILE* output_file) {
    //All should skip
    registers->i_reg = 0520;
    registers->ac_reg = 04001;
    registers->l_reg = 01;
    registers->result_ac = 04001;
    registers->result_link = 01;
    registers->skip = 1;
    registers->micro_g1 = 0;
    registers->micro_g2 = 1;
    registers->micro_g3 = 0;
    strncpy(registers->opcodes, "SMA,SNL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0460;
    registers->ac_reg = 00000;
    registers->l_reg = 01;
    registers->result_ac = 00000;
    registers->result_link = 01;
    strncpy(registers->opcodes, "SZA,SNL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);
}

void group2_and_directed_tests(regs* registers, FILE* output_file) {
    registers->i_reg = 0550;
    registers->ac_reg = 04001;
    registers->l_reg = 00;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 1;
    registers->micro_g3 = 0;
    strncpy(registers->opcodes, "SPA,SNA", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0550;
    registers->ac_reg = 00000;
    registers->l_reg = 00;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SPA,SNA", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0550;
    registers->ac_reg = 00001;
    registers->l_reg = 00;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 1;
    strncpy(registers->opcodes, "SPA,SNA", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    //SPA,SZL
    registers->i_reg = 0530;
    registers->ac_reg = 04001;
    registers->l_reg = 01;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SPA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0530;
    registers->ac_reg = 04001;
    registers->l_reg = 00;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SPA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0530;
    registers->ac_reg = 00001;
    registers->l_reg = 01;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SPA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0530;
    registers->ac_reg = 00001;
    registers->l_reg = 00;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 1;
    strncpy(registers->opcodes, "SPA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    //SNA, SZL
    registers->i_reg = 0470;
    registers->ac_reg = 00000;
    registers->l_reg = 01;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SNA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0470;
    registers->ac_reg = 00001;
    registers->l_reg = 01;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SNA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0470;
    registers->ac_reg = 00000;
    registers->l_reg = 01;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SNA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0470;
    registers->ac_reg = 00001;
    registers->l_reg = 00;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 1;
    strncpy(registers->opcodes, "SNA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    //SPA, SNA, SZL
    registers->i_reg = 0570;
    registers->ac_reg = 04001;
    registers->l_reg = 01;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SPA,SNA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0570;
    registers->ac_reg = 04001;
    registers->l_reg = 00;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SPA,SNA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0570;
    registers->ac_reg = 00001;
    registers->l_reg = 01;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    strncpy(registers->opcodes, "SPA,SNA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);

    registers->i_reg = 0570;
    registers->ac_reg = 00001;
    registers->l_reg = 00;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 1;
    strncpy(registers->opcodes, "SPA,SNA,SZL", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);
}

void group3_tests(regs* registers, FILE* output_file) {
    registers->i_reg = 0401;
    registers->ac_reg = 04001;
    registers->l_reg = 01;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 0;
    registers->micro_g3 = 1;
    strncpy(registers->opcodes, "group3", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file); 

    registers->i_reg = 0411;
    registers->ac_reg = 04001;
    registers->l_reg = 01;
    registers->result_ac = registers->ac_reg;
    registers->result_link = registers->l_reg;
    registers->skip = 0;
    registers->micro_g1 = 0;
    registers->micro_g2 = 0;
    registers->micro_g3 = 1;
    strncpy(registers->opcodes, "group3", OPCODE_TEXT_SIZE-1);
    write_regs(registers, output_file);
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
    strncpy(registers->opcodes, "CLA", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "CLL", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "CMA", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "CML", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "IAC", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "RAR", OPCODE_TEXT_SIZE-1);
}

//FIXME: Does not work as expected
//Doing two RAR in a row and then resetting the inputs to the right value
void RTR(regs* registers, uint16_t ac, uint8_t link) {
    RAR(registers, ac, link);
    RAR(registers, registers->ac_reg, link);

    registers->i_reg = 0012;
    registers->ac_reg = ac;
    registers->l_reg = link;
    strncpy(registers->opcodes, "RTR", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "RAL", OPCODE_TEXT_SIZE-1);
}

//FIXME: Does not work as expected
//Doing two RAL in a row and then resetting the inputs to the right value
void RTL(regs* registers, uint16_t ac, uint8_t link) {
    RAL(registers, ac, link);
    RAL(registers, registers->ac_reg, registers->l_reg);

    registers->i_reg = 0006;
    registers->ac_reg = ac;
    registers->l_reg = link;
    strncpy(registers->opcodes, "RTL", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "SMA", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "SZA", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "SNL", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "SPA", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "SNA", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "SZL", OPCODE_TEXT_SIZE-1);
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
    strncpy(registers->opcodes, "MQL", OPCODE_TEXT_SIZE-1);
}

