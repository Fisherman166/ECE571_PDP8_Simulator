// Divide
// Jonathan Waldrip

module Divide (input  logic        clock     ,
               input  logic [23:0] dividend  ,
               input  logic [11:0] divisor   ,        
               input  logic        start     ,        
               output logic [11:0] quotient  ,
               output logic [11:0] remainder ,
               output logic        link_out  ,
               output logic        finished  
               );      

logic [23:0] regp       ;
logic [11:0] regm       ;
logic        load       ;
logic        shift      ;
logic        sub        ;
logic        dosub      ;
logic [12:0] subtractor ;
int          counter    ;
logic        en_cnt     ;
logic        cntnm1     ;

typedef enum {S0, S1, S2, S3} STATE_TYPE;
STATE_TYPE current_state, next_state;

assign quotient   = regp[11: 0];
assign remainder  = regp[23:12];
assign subtractor = regp[23:11] - {1'b0,regm};
assign dosub      = !subtractor[12];

// regm
always_ff @(posedge clock) begin
     if (load === 1) regm <= divisor;
end     

// regp
always_ff @(posedge clock) begin
     if (load === 1) regp <= dividend;
     else if (shift === 1) begin
          if (regp[23] === 1) link_out <= 1;
          else link_out <= 0;
          regp <= {regp[22:0],1'b0};
          end
     else if (sub === 1) regp <= {subtractor[11:0],regp[10:0],1'b1}; 
end

// counter
always_ff @(posedge clock) begin
     if (en_cnt === 1) counter <= counter + 1;
     else counter <= 0;
end      

assign cntnm1 = (counter === 11) ? 1 : 0 ;

// State Register
always_ff @(posedge clock) begin
     current_state <= next_state;
end

// Next state logic
always_comb begin
     load     = 0 ;  // default
     sub      = 0 ;
     shift    = 0 ;
     en_cnt   = 0 ;
     finished = 0 ;
     next_state = current_state;
	case (current_state)
          S0:  begin
               if (start === 1) begin
                    load = 1;
                    next_state = S1;
                    end
               end  
               
          S1:  begin
               en_cnt = 1;
               if (dosub === 1) sub = 1;
               else shift = 1;
               if (cntnm1 === 1) next_state = S2;     
               end
               
          S2:  begin
               finished = 1;
               if (start === 0) next_state = S0;
               else next_state = S3;
               end 
               
          S3:  next_state = S0;
          
     default: next_state = S0;
               
	endcase
end
         
endmodule

