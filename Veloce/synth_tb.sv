// Synthesizable testbench for PDP8 project - ECE 571
// Jonathan Waldrip and Sean Koppenhafer

`include "CPU_Definitions.pkg"
`include "memory_utils.pkg"

/******************************** Declare Module Ports **********************************/

module synth_tb ();
    logic   clk         ;
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
      
    /********************************* Instatiate Modules **********************************/

    Top TOP0 (.btnc(Display_Select) ,
              .btnu(Step          ) ,
              .btnd(Deposit       ) ,
              .btnl(Load_PC       ) ,
              .btnr(Load_AC       ) ,             
              .*);    
     
    /************************************** Main Body **************************************/
    // Generate clock signal
    //tbx clkgen
    initial begin
        clk = 0;
        forever begin
            #10 clk = ~clk;  
        end
    end

    always @(negedge led[12]) begin
        integer output_file = $fopen("mem_out.txt");
        $writememh(output_file, TOP0.MEM0.memory);
        $fclose(output_file);
        $finish();
    end

    // Run test
    initial begin
        // Hold reset low on DUT for 5 clock cycles
        btnCpuReset = 0;
        repeat(5) @ (negedge clk); btnCpuReset = 1;

        // read compiled asm file from pal assembler using pal -o option
        integer file = $fopen("init_mem.txt", "r");
        $readmemh(file, TOP0.MEM0.memory);
        $fclose(file);

        // Set program counter to 200
        set_pc(12'o200);

        // Run program
        repeat(10) @ (negedge clk); sw[12] = 1;
    end 

    function void set_pc(input word pc);
        repeat(10) @ (negedge clk); sw[11:0] = pc;
        repeat(10) @ (negedge clk); Load_PC = 1;
        repeat(10) @ (negedge clk); Load_PC = 0; 
    endfunction
endmodule
