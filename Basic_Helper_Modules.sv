// -------------------- Basic Helper Modules --------------------

`timescale 1ns/1ps

// ---------------------------- Adder ----------------------------
module PC_Adder (a,b,c);
    input [31:0] a, b;
    output [31:0] c;
    assign c = a + b;
endmodule

// ------------------------- Multiplexer -------------------------
module Mux (a,b,s,c);
  	input [31:0] a, b;
    input s;
    output [31:0] c;
    assign c = (~s) ? a : b;
endmodule
