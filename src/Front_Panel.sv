// CPU for PDP8 Project
// Jonathan Waldrip

`include "CPU_Definitions.pkg"


/******************************** Declare Module Ports **********************************/

module Front_Panel (input logic clock         ,
                    input logic resetN        ,
                    front_panel_pins.slave fp ,
                    output logic [15:0] led   ,
                    output logic [ 7:0] an    ,
                    output logic [ 6:0] seg   ,
                    output logic        dp    ,
                    input  logic [12:0] sw    ,
                    input  logic        btnc  ,
                    input  logic        btnu  ,
                    input  logic        btnd  ,
                    input  logic        btnl  ,
                    input  logic        btnr              
                    );

/********************************** Declare Signals ************************************/                    

logic [20:0] digit_mux_counter               ;
logic [ 2:0] digit_mux                       ;
logic [ 2:0] digit_drive                     ;
int   m1counter                              ;
logic count0, disp_d                         ;
typedef enum {b0, b1, b2, b3} DEB_STATE      ;
typedef enum {d0, d1, d2, d3} DISP_STATE     ; 
DISP_STATE cur_state_disp, next_state_disp   ;
DEB_STATE cur_state_deb, next_state_deb      ;


/************************************** Main Body **************************************/

assign fp.swreg = sw[11:0];
assign dp = (digit_mux === 3'b011) ? ~fp.linkout : 1;
assign count0 = (m1counter === 0) ? 1:0;
assign led[15] = sw[12];
assign fp.run = sw[12];
assign led[14:4] = 0;


 // divide by 1,000,000 counter (low pass filter)
always_ff @ (posedge clock) begin
     if (m1counter === 5) m1counter <= 0; // 5 for simulation
     else m1counter <= m1counter + 1;
end


// 7 Segment display
// 2^20 counter
always_ff @ (posedge clock) begin
     digit_mux_counter <= digit_mux_counter + 1;
end     

assign digit_mux = digit_mux_counter[20:18];

// 1 of 8 decoder
assign an = (digit_mux === 3'b000) ?  8'b11111110 :
            (digit_mux === 3'b001) ?  8'b11111101 :
            (digit_mux === 3'b010) ?  8'b11111011 :
            (digit_mux === 3'b011) ?  8'b11110111 :
            (digit_mux === 3'b100) ?  8'b11101111 :
            (digit_mux === 3'b101) ?  8'b11011111 :
            (digit_mux === 3'b110) ?  8'b10111111 :
                                      8'b01111111 ;
            
// 12 to 4 multiplexer + unused digits
assign digit_drive = (digit_mux === 3'b000) ? fp.dispout[ 2:0] :
                     (digit_mux === 3'b001) ? fp.dispout[ 5:3] :
                     (digit_mux === 3'b010) ? fp.dispout[ 8:6] :
                     (digit_mux === 3'b011) ? fp.dispout[11:9] : 0;

// digit to cathode mappping function
always_comb begin
	case (digit_drive) 
          3'b000 :   seg = 8'b1000000;
          3'b001 :   seg = 8'b1111001;
          3'b010 :   seg = 8'b0100100;
          3'b011 :   seg = 8'b0110000;
          3'b100 :   seg = 8'b0011001;
          3'b101 :   seg = 8'b0010010;
          3'b110 :   seg = 8'b0000010;
          3'b111 :   seg = 8'b1111000;
		default:   seg = 8'b0000000;
	endcase
end

// Next state register
always_ff @ (posedge clock, negedge resetN) begin
     if (!resetN) begin
          cur_state_disp <= d0;
          cur_state_deb  <= b0;
     end     
     else begin
		cur_state_disp <= next_state_disp;
		cur_state_deb  <= next_state_deb ;
	end
end

//Display selection state machine
always_comb begin
	fp.dispsel = 2'b01;
	led[3:0] = 0;
	next_state_disp <= cur_state_disp;
	unique case (cur_state_disp) 
		d0:  begin 
                    fp.dispsel   = 2'b00;
                    led [3:0] = 4'b0001;
                    if (disp_d === 1) next_state_disp <= d1;
               end
               
		d1:  begin 
                    fp.dispsel   = 2'b01;
                    led [3:0] = 4'b0010;
                    if (disp_d === 1) next_state_disp <= d2;
               end
               
		d2:  begin 
                    fp.dispsel   = 2'b10;
                    led [3:0] = 4'b0100;
                    if (disp_d === 1) next_state_disp <= d3;
               end
               
		d3:  begin 
                    fp.dispsel   = 2'b11;
                    led [3:0] = 4'b1000;
                    if (disp_d === 1) next_state_disp <= d0;
               end
     endcase
end

//Oneshot state machine for button debounce
always_comb begin
	fp.loadac  = 0;
	fp.loadpc  = 0;
	fp.step    = 0;
	fp.deposit = 0;
	   disp_d  = 0;
	next_state_deb = cur_state_deb;
     
	unique case (cur_state_deb)
		b0:  if (btnl === 1 || 
                   btnr === 1 || 
                   btnu === 1 || 
                   btnd === 1 || 
                   btnc === 1) next_state_deb = b1;

		b1:  if (count0 === 1) next_state_deb = b2;

		b2:  begin
               fp.loadpc      = btnl;
               fp.loadac      = btnr;                              
               fp.step        = btnu;               
               fp.deposit     = btnd;               
                  disp_d      = btnc;               
               next_state_deb = b3;               
               end               
            
		b3:  if (btnl === 0 && 
                   btnr === 0 && 
                   btnu === 0 && 
                   btnd === 0 && 
                   btnc === 0) next_state_deb = b0;
	endcase
end



endmodule