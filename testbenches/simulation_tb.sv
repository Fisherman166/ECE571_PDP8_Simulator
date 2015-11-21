// Simulation testbench for PDP8 project - ECE 571
// Jonathan Waldrip and Sean Koppenhafer

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"

`define FILL_DEBUG
     
/******************************** Declare Module Ports **********************************/

module simulation_tb ();
    parameter string INIT_MEM_FILENAME = "init_mem.obj";
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
    int          m;  
    int          line_count = 0;
    int          file, read_count1, read_count2;               
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
        //print_valid_memory();
        trace_close();
        $finish();
    end

    // Run test
    initial begin
        trace_init();
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
        print_valid_memory();

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
endmodule
