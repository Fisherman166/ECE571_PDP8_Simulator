// Multiply
// Jonathan Waldrip

module Multiply    (input  logic        clock        ,
                    input  logic [11:0] multiplier   ,
                    input  logic [11:0] multiplicand ,          
                    input  logic        start        ,          
                    output logic [23:0] product      , 
                    output logic        finished     
                    );      


logic [23:0] regp   ;
logic [11:0] regm   ;
logic        load   ;
logic        shift  ;
logic        add    ;
logic        doadd  ;
logic [12:0] adder  ;
int          counter;
logic        en_cnt ;
logic        cntnm1 ;

typedef enum {S0, S1, S2, S3} STATE_TYPE;
STATE_TYPE current_state, next_state;

assign product = regp;
assign adder = {1'b0,regp[23:12]} + {1'b0,regm};
assign doadd = regp[0];

// regm
always_ff @(posedge clock) begin
     if (load == 1) regm <= multiplier;
end     

// regp
always_ff @(posedge clock) begin
     if (load == 1) regp <= multiplicand;
     else if (shift == 1) regp <= regp[23:1];
     else if (add == 1) regp <= {adder,regp[11:1]};
end

// counter
always_ff @(posedge clock) begin
     if (en_cnt == 1) counter <= counter + 1;
     else counter <= 0; 
end      

assign cntnm1 = (counter == 11) ? 1 : 0 ;

// State Register
always_ff @(posedge clock) begin
     current_state <= next_state;
end

// Next state logic
always_comb begin
     load     = 0 ;  // default
     add      = 0 ;
     shift    = 0 ;
     en_cnt   = 0 ;
     finished = 0 ;
     next_state = current_state;
	case (current_state)
		S0:  begin
               if (start == 1) begin 
                    load = 1;
                    next_state = S1;
                    end
               end
               
		S1:  begin
               en_cnt = 1;
               if (doadd == 1) add = 1;
               else shift = 1;
               if (cntnm1 == 1) next_state = S2;     
               end
               
		S2:  begin
               finished = 1;
               if (start == 0) next_state = S0;
               else next_state = S3;
               end
               
		S3:  next_state = S0;
          
     default:  next_state = S0;
    
	endcase
end
         
endmodule

