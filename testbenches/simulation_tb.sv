// Simulation testbench for PDP8 project - ECE 571
// Jonathan Waldrip and Sean Koppenhafer

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"

//`define FILL_DEBUG
`define NO_OPCODE_TEXT

//Defines for easy access to signals
`define READ_ENABLE     read_enable
`define MEM_FINISHED    mem_finished
`define MEM_ADDRESS     address
`define MEM_VALID       memory[`MEM_ADDRESS].valid
`define MEM_READ_DATA   read_data
`define MEM_DATA        memory[`MEM_ADDRESS].data
`define MEM_WRITE_DATA  write_data
`define IR_REG          curr_reg.ir

//Opcodes for instruction text
`define OPCODE_AND     3'o0
`define OPCODE_TAD     3'o1
`define OPCODE_ISZ     3'o2
`define OPCODE_DCA     3'o3
`define OPCODE_JMS     3'o4
`define OPCODE_JMP     3'o5

// Group 1 micro instructions
`define MICRO_INSTRUCTION_CLA 12'o7200
`define MICRO_INSTRUCTION_CLL 12'o7100
`define MICRO_INSTRUCTION_CMA 12'o7040
`define MICRO_INSTRUCTION_CML 12'o7020
`define MICRO_INSTRUCTION_IAC 12'o7001
`define MICRO_INSTRUCTION_RAR 12'o7010
`define MICRO_INSTRUCTION_RTR 12'o7012
`define MICRO_INSTRUCTION_RAL 12'o7004
`define MICRO_INSTRUCTION_RTL 12'o7006

// Group 2 micro instructions
`define MICRO_INSTRUCTION_SMA 12'o7500
`define MICRO_INSTRUCTION_SZA 12'o7440
`define MICRO_INSTRUCTION_SNL 12'o7420
`define MICRO_INSTRUCTION_SPA 12'o7510
`define MICRO_INSTRUCTION_SNA 12'o7450
`define MICRO_INSTRUCTION_SZL 12'o7430
`define MICRO_INSTRUCTION_SKP 12'o7410
`define MICRO_INSTRUCTION_CLA2 12'o7600
`define MICRO_INSTRUCTION_OSR 12'o7404
`define MICRO_INSTRUCTION_HLT 12'o7402

//Group 3 micro instructions
`define MICRO_INSTRUCTION_CLA3 12'o7601
`define MICRO_INSTRUCTION_MQL 12'o7421
`define MICRO_INSTRUCTION_MQA 12'o7501
`define MICRO_INSTRUCTION_SWP 12'o7521
`define MICRO_INSTRUCTION_CAM 12'o7621


/******************************** Declare Module Ports **********************************/

module simulation_tb ();
    parameter string INIT_MEM_FILENAME = "init_mem.obj";
    parameter string MEM_TRACE_FILENAME = "memory_trace_sv.txt";
    parameter string REG_TRACE_FILENAME = "opcodes_sv.txt";
    parameter string VALID_MEM_FILENAME  = "valid_memory_sv.txt";
    parameter string BRANCH_TRACE_FILENAME  = "branch_trace_sv.txt";
    bit   clk         ;
    logic btnCpuReset = 1 ;
    logic [15:0] led  ;
    logic [ 7:0] an   ;
    logic [ 6:0] seg  ;
    logic        dp   ;
    logic [12:0] sw   = 0;
    logic        Display_Select = 0 ;
    logic        Step    = 0 ;
    logic        Deposit = 0 ;
    logic        Load_PC = 0 ;
    logic        Load_AC = 0 ;
    int          file, read_count1, read_count2;               
    int          mem_trace_file, reg_file, branch_file; 
    bit   [11:0] high_byte, low_byte;
    word         word_value;
    Controller_states_t CPU_State;
    logic [11:0] pc_temp;
    logic        cond_skip_flag = 0;
    logic [11:0] read_data ;  
    logic        mem_finished ;		  
    memory_element  memory[`PAGES * `WORDS_PER_PAGE];    		  
    PDP8_Registers_t curr_reg  ;   		  
    Controller_states_t Curr_State;		  
    logic [11:0] address;      		  
    logic [11:0] write_data ;  		  
    logic 	  write_enable; 		  
    logic        read_enable ; 		  
    logic        read_type ;

      
    /********************************* Instatiate Modules **********************************/

    Top TOP0 (.btnc(Display_Select) ,
              .btnu(Step          ) ,
              .btnd(Deposit       ) ,
              .btnl(Load_PC       ) ,
              .btnr(Load_AC       ) ,
              .*);    
     
    /************************************** Main Body **************************************/
    assign CPU_State = Curr_State; 
     
    // Generate clock signal
    always #10 clk = ~clk;  

    always @(negedge led[12]) begin
        print_valid_memory();
        $fclose(mem_trace_file);
        $fclose(reg_file);
        $fclose(branch_file);
        $finish();
    end

    //Print contents of all registers after each instruction
    always @(posedge led[13]) begin
        automatic string instruction_text = "";

        //Only print this 
        if(led[12]) begin
            //For non-micro instructions
            if(curr_reg.ir[11:9] < 3'o7) begin
                unique case(curr_reg.ir[11:9])
                    `OPCODE_AND: instruction_text = "AND";
                    `OPCODE_TAD: instruction_text = "TAD";
                    `OPCODE_ISZ: instruction_text = "ISZ";
                    `OPCODE_DCA: instruction_text = "DCA";
                    `OPCODE_JMS: instruction_text = "JMS";
                    `OPCODE_JMP: instruction_text = "JMP";
                endcase
            end
            else begin
                //Group 1 instruction
                if(!`IR_REG[8]) begin
                    if(decode_micro_ops(`MICRO_INSTRUCTION_CLA)) instruction_text = {instruction_text, "CLA "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_CLL)) instruction_text = {instruction_text, "CLL "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_CMA)) instruction_text = {instruction_text, "CMA "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_CML)) instruction_text = {instruction_text, "CML "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_IAC)) instruction_text = {instruction_text, "IAC "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_RTR)) instruction_text = {instruction_text, "RTR "};
                    else if(decode_micro_ops(`MICRO_INSTRUCTION_RAR)) instruction_text = {instruction_text, "RAR "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_RTL)) instruction_text = {instruction_text, "RTL "};
                    else if(decode_micro_ops(`MICRO_INSTRUCTION_RAL)) instruction_text = {instruction_text, "RAL "};
                end
                else if(`IR_REG[8] && !`IR_REG[0]) begin //Group 2
                    if(`IR_REG === `MICRO_INSTRUCTION_SKP) instruction_text = {instruction_text, "SKP "};
                    else if(!`IR_REG[3]) begin //Group 2 OR
                        if(decode_micro_ops(`MICRO_INSTRUCTION_SMA)) instruction_text = {instruction_text, "SMA "};
                        if(decode_micro_ops(`MICRO_INSTRUCTION_SZA)) instruction_text = {instruction_text, "SZA "};
                        if(decode_micro_ops(`MICRO_INSTRUCTION_SNL)) instruction_text = {instruction_text, "SNL "};
                    end
                    else begin //Group 2 AND
                        if(decode_micro_ops(`MICRO_INSTRUCTION_SPA)) instruction_text = {instruction_text, "SPA "};
                        if(decode_micro_ops(`MICRO_INSTRUCTION_SNA)) instruction_text = {instruction_text, "SNA "};
                        if(decode_micro_ops(`MICRO_INSTRUCTION_SZL)) instruction_text = {instruction_text, "SZL "};
                    end
                    if(decode_micro_ops(`MICRO_INSTRUCTION_CLA2)) instruction_text = {instruction_text, "CLA "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_OSR)) instruction_text = {instruction_text, "OSR "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_HLT)) instruction_text = {instruction_text, "HLT "};
                end
                else begin //Group 3
                    if(decode_micro_ops(`MICRO_INSTRUCTION_CLA3)) instruction_text = {instruction_text, "CLA "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_MQL)) instruction_text = {instruction_text, "MQL "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_MQA)) instruction_text = {instruction_text, "MQA "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_SWP)) instruction_text = {instruction_text, "SWP "};
                    if(decode_micro_ops(`MICRO_INSTRUCTION_CAM)) instruction_text = {instruction_text, "CAM "};
                end
            end

            `ifndef NO_OPCODE_TEXT
                $fdisplay(reg_file, "Opcode %s: %03o, AC: %o, Link: %b, MB: %o, PC: %o, CPMA: %o", 
                          instruction_text, curr_reg.ir[11:9], curr_reg.ac, curr_reg.lk,
                          curr_reg.mb, curr_reg.pc, curr_reg.ea);
            `else
                $fdisplay(reg_file, "Opcode: %03o, AC: %o, Link: %b, MB: %o, PC: %o, CPMA: %o", 
                          curr_reg.ir[11:9], curr_reg.ac, curr_reg.lk,
                          curr_reg.mb, curr_reg.pc, curr_reg.ea);
            `endif
        end
    end

    //Generate memory trace file
    always @(posedge `MEM_FINISHED) begin
        if(led[12]) begin //This is high when the program is running
            if(`READ_ENABLE) begin
                if(`MEM_VALID === 1'b0) begin
                    $fdisplay(mem_trace_file, "ERROR: Attempting to read from invalid address %04o", `MEM_ADDRESS);
                end
                else begin
                    if(read_type === `DATA_READ) begin
                        $fdisplay(mem_trace_file, "DR %04o %04o %04o", `MEM_ADDRESS, `MEM_READ_DATA, `MEM_DATA);
                    end
                    else begin
                        $fdisplay(mem_trace_file, "IF %04o %04o %04o", `MEM_ADDRESS, `MEM_READ_DATA, `MEM_DATA);
                    end
                end
            end
            else if(write_enable) begin
                $fdisplay(mem_trace_file, "DW %04o %04o %04o", `MEM_ADDRESS, `MEM_WRITE_DATA, `MEM_DATA);
            end
            else $display(mem_trace_file, "Neither read nor write");
        end //if led
    end //always

    //Generates branch trace file
    always_comb begin
        if (CPU_State === JMS_1) begin
            $fdisplay(branch_file, "Current PC: %04o, Target: %04o, Type: Subroutine, Result: Taken",
                      curr_reg.pc, curr_reg.ea + 1);
        end
        if (CPU_State === JMP_1) begin
            $fdisplay(branch_file, "Current PC: %04o, Target: %04o, Type: Unconditional, Result: Taken",
                      curr_reg.pc, curr_reg.ea);
        end
                    
        // If microcoded group2 or ISZ, record current PC to temp and set flag              
        if ((CPU_State === MIC_2) || (CPU_State === ISZ_1)) begin 
            pc_temp = curr_reg.pc;
            if( (`IR_REG === `MICRO_INSTRUCTION_OSR) ) cond_skip_flag = 0;
            else cond_skip_flag = 1;
        end 
        // If returned to idle state and flag is 1, print trace info
        else if ( ((CPU_State === CPU_IDLE) || (CPU_State === HALT))  && cond_skip_flag && led[12]) begin
            cond_skip_flag = 0;
            if(`IR_REG === `MICRO_INSTRUCTION_SKP) 
                $fdisplay(branch_file, "Current PC: %04o, Target: %04o, Type: Unconditional, Result: Taken",
                          pc_temp, pc_temp + 1);
            else if ((curr_reg.pc - pc_temp) !== 0) 
            $fdisplay(branch_file, "Current PC: %04o, Target: %04o, Type: Conditional, Result: Taken",
                      pc_temp, pc_temp + 1);
            else
            $fdisplay(branch_file, "Current PC: %04o, Target: %04o, Type: Conditional, Result: Not Taken",
                      pc_temp, pc_temp + 1);
        end     
    end

    // Run test
    initial begin
        init_output_files();

        // Hold reset low on DUT for 5 clock cycles
        btnCpuReset = 0;
        repeat(5) @ (negedge clk); btnCpuReset = 1;

        // read compiled asm file from pal assembler using pal -o option
        file = $fopen(INIT_MEM_FILENAME, "r");
        if(file == 0) $display("Failed to open memory file");
        while(!$feof(file)) begin
             read_count1 = $fscanf(file, "%03o", high_byte);
             read_count2 = $fscanf(file, "%03o", low_byte);
             if($feof(file)) break;
             word_value = {high_byte[5:0], low_byte[5:0]};

            `ifdef FILL_DEBUG
                $display("From file - high: %03o, low: %03o", high_byte, low_byte);
                $display("Word value = %04o", word_value);
            `endif

            if(high_byte[6]) begin
                set_pc(word_value);
                `ifdef FILL_DEBUG
                    $display("Address changed to: %04o", word_value);
                `endif
            end
            else begin
                write_data2(word_value);
                `ifdef FILL_DEBUG
                    $display("Memory value: %04o", word_value);
                `endif
            end    
            repeat(1) @ (negedge clk);
        end
        $fclose(file);

        // Set program counter to 200
        set_pc(12'o200);

        // Run program
        repeat(10) @ (negedge clk); sw[12] = 1;

    end 

    task set_pc(input word pc);
        repeat(10) @ (negedge clk); sw[11:0] = pc;
        repeat(10) @ (negedge clk); Load_PC = 1;
        repeat(10) @ (negedge clk); Load_PC = 0; 
    endtask

    task write_data2(input word data);
        repeat(10) @ (negedge clk); sw[11:0] = data;
        repeat(10) @ (negedge clk); Deposit = 1;
        repeat(10) @ (negedge clk); Deposit = 0;
    endtask

    function void print_valid_memory();
        automatic integer file = $fopen(VALID_MEM_FILENAME, "w");

        `ifdef SIMULATION
            if(!file) $display ("Error opening valid_memory_sv.txt file");
        `endif

		$fdisplay(file, "Address    Contents");
		$fdisplay(file, "-------    --------");

		for(int i = 0; i < `PAGES * `WORDS_PER_PAGE; i++) begin
			if(memory[i].valid === 1'b1) begin
				$fdisplay(file, "%04o        %04o", i, memory[i].data);
			end //if
		end //for

        $fclose(file);
	endfunction

    function void init_output_files();
        //Open different trace files
        mem_trace_file = $fopen(MEM_TRACE_FILENAME, "w");
        if(!mem_trace_file) $display("ERROR: Failed to open memory trace file.");
        $fdisplay(mem_trace_file, "OP Addr Bus  Mem ");
        $fdisplay(mem_trace_file, "-- ---- ---- ----");

        reg_file = $fopen(REG_TRACE_FILENAME, "w");
        if(!reg_file) $display ("Error opening reg trace file");
        
        branch_file = $fopen(BRANCH_TRACE_FILENAME, "w");
        if(!branch_file) $display("Error opening branch trace file");
    endfunction

    function logic decode_micro_ops(input word micro_op);
        automatic logic retval = '0;
        if((`IR_REG & micro_op) === micro_op) retval = 1'b1;
        return retval;
    endfunction
endmodule
