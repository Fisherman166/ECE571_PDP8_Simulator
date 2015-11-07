// BarrelShifter.v
// Jonathan Waldrip
// 2015.10.02
// This barrel shifter shifts the input to the left by the number of bits specified by the ShiftAmount input.

// The ShiftIn input determines if the values shifted in are 1's or 0's
// The bit-width of the input and output are parameterized by a single parameter (size), 
// and the module automatically adjusts the size of the ShiftAmount input accordingly.
// For example, if the default value of 32 is used for bit-width of input and output, the 
// ShiftAmount input will be 5 bits wide. If the input and output are resized to 8 bits,
// then the ShiftAmount input will only be 3 bits wide (lg(8) = 3).  

// Code sources:
// For log base 2 calculation: http://www.edaboard.com/thread177879.html , user Meher81

`timescale 1ns/1ns

// Module declaration
module BarrelShifter(In, ShiftAmount, ShiftIn, Out);
parameter size = 32;                    // Parameter for bit-width of input and output
input [size-1:0] In;                    // Input vector
input [clogb2(size)-1:0] ShiftAmount;   // Determines # of bits to shift
input ShiftIn;                          // Single-bit input to determine whether to shift in 1's or 0's
output[size-1:0] Out;                   // Left shifted output

// Declare internal signals
reg in_w = (size);                      // Variable to pass size parameter to log base 2 function
wire [size-1:0] fill;                   // wire to be all 1's or 0's to shift in  
wire [size-1:0] X [clogb2(size):0];     // array of wires to connect muxes together

// Setup up values to shift in
assign fill = (ShiftIn) ? ~0 : 0;       // If ShiftIn is 1, make fill all 1's, else all 0's
                                        // (bitwise not 0 = all 1's)
// Instantiate 2x1 multiplexers    
assign X[clogb2(size)] = In;            // Unshifted input to first mux
assign Out = X[0];                      // Assign last mux output to output of module


genvar j;                                                        // Variable for loop count in generate block
generate for (j = clogb2(size)-1; j > -1; j = j - 1) begin: M    // an instance for every bit in ShiftAmount
     Mux_2x1  #(size) mux (                                      // Pass size parameter to mux modules
          .in0 ( X[j+1]),                                        // Unshifted input
          .in1 ({X[j+1][(size-(2**j)-1):0],fill[((2**j)-1):0]}), // Shifted input
          .out ( X[j]),                                          // Output to next iteration
          .sel (ShiftAmount[j])                                  // ShiftAmount becomes select bits
     );                                                           
     end
endgenerate


// Function to calculate log base 2 of the size parameter to autosize ShiftAmount width
// Thanks to user Meher81, http://www.edaboard.com/thread177879.html  
function integer clogb2;                     // Declare function
     input [31:0] in_w;                      // Input value to function, set equal to (size) parameter
     integer i;                              // loop counter
     begin
          clogb2 = 0;                        // Initial value of 0
          for(i = 0; 2**i < in_w; i = i + 1) // Increment i until 2^i > size, this will be lg(size).
          clogb2 = i + 1;
     end
endfunction

endmodule