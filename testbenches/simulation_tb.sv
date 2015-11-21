// Simulation testbench for PDP8 project - ECE 571
// Jonathan Waldrip and Sean Koppenhafer

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"

//`define FILL_DEBUG

`define READ_ENABLE     TOP0.bus.read_enable
`define MEM_FINISHED    TOP0.bus.mem_finished
`define MEM_ADDRESS     TOP0.bus.address
`define MEM_VALID       TOP0.MEM0.memory[`MEM_ADDRESS].valid
`define MEM_READ_DATA   TOP0.bus.read_data
`define MEM_DATA        TOP0.MEM0.memory[`MEM_ADDRESS].data
`define MEM_WRITE_DATA  TOP0.bus.write_data
     
/******************************** Declare Module Ports **********************************/

module simulation_tb ();
    parameter string INIT_MEM_FILENAME = "init_mem.obj";
    parameter string MEM_TRACE_FILENAME = "memory_trace_sv.txt";
    parameter string REG_TRACE_FILENAME = "opcode_output.txt";
    parameter string VALID_MEM_FILENAME  = "valid_memory_sv.txt";
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
    int          mem_trace_file, reg_file; 
    bit   [11:0] high_byte, low_byte;
    word         word_value;

      
    /********************************* Instatiate Modules **********************************/

    Top TOP0 (.btnc(Display_Select) ,
              .btnu(Step          ) ,
              .btnd(Deposit       ) ,
              .btnl(Load_PC       ) ,
              .btnr(Load_AC       ) ,             
              .*);    
     
    /************************************** Main Body **************************************/
     
    // Generate clock signal
    always #10 clk = ~clk;  

    always @(negedge TOP0.led[12]) begin
        print_valid_memory();
        $fclose(mem_trace_file);
        $fclose(reg_file);
        $finish();
    end

    //Print contents of all registers after each instruction
    always @(posedge led[13]) begin
        if(led[12]) begin
            $fdisplay(reg_file, "Opcode: %03o, AC: %o, Link: %b, MB: %o, PC: %o, CPMA: %o", 
                      TOP0.bus.curr_reg.ir[11:9], TOP0.bus.curr_reg.ac, TOP0.bus.curr_reg.lk,
                      TOP0.bus.curr_reg.mb, TOP0.bus.curr_reg.pc, TOP0.bus.curr_reg.ea);
        end
    end

    //Generate memory trace file
    always @(posedge `MEM_FINISHED) begin
        if(TOP0.led[12]) begin //This is high when the program is running
            if(`READ_ENABLE) begin
                if(`MEM_VALID === 1'b0) begin
                    $fdisplay(mem_trace_file, "ERROR: Attempting to read from invalid address %04o", `MEM_ADDRESS);
                end
                else begin
                    if(TOP0.bus.read_type === `DATA_READ) begin
                        $fdisplay(mem_trace_file, "DR %04o %04o %04o", `MEM_ADDRESS, `MEM_READ_DATA, `MEM_DATA);
                    end
                    else begin
                        $fdisplay(mem_trace_file, "IF %04o %04o %04o", `MEM_ADDRESS, `MEM_READ_DATA, `MEM_DATA);
                    end
                end
            end
            else if(TOP0.bus.write_enable) begin
                $fdisplay(mem_trace_file, "DW %04o %04o %04o", `MEM_ADDRESS, `MEM_WRITE_DATA, `MEM_DATA);
            end
            else $display(mem_trace_file, "Neither read nor write");
        end //if led
    end //always

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
                write_data(word_value);
                `ifdef FILL_DEBUG
                    $display("Memory value: %04o", word_value);
                `endif
            end    
            repeat(1) @ (negedge clk);
        end
        $fclose(file);

        // Set program counter to 200
        set_pc(12'o200);
        //print_valid_memory();

        // Run program
        repeat(10) @ (negedge clk); sw[12] = 1;

    end 

    task set_pc(input word pc);
        repeat(10) @ (negedge clk); sw[11:0] = pc;
        repeat(10) @ (negedge clk); Load_PC = 1;
        repeat(10) @ (negedge clk); Load_PC = 0; 
    endtask

    task write_data(input word data);
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
			if(TOP0.MEM0.memory[i].valid === 1'b1) begin
				$fdisplay(file, "%04o        %04o", i, TOP0.MEM0.memory[i].data);
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
    endfunction
endmodule
