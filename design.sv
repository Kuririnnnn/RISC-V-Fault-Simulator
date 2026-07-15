// ---------------- Top Module (Comparison of Golden and Faulty) ----------------
`include "Basic_Helper_Modules.sv"
`include "Shared_Decoder_Modules.sv"
`include "Golden_Datapath_Control.sv"
`include "Golden_Memory_Modules.sv"
`include "Faulty_Datapath_Control.sv"
`include "Faulty_Memory_Modules.sv"
`include "Golden_Top.sv"
`include "Faulty_Top.sv"
`timescale 1ns/1ps

// ------------------------ Single Cycle Top Comparison ------------------------
// Wraps the already-wired Single_Cycle_Top / Single_Cycle_Top_faulty modules
// (defined in Golden_Top.sv / Faulty_Top.sv) instead of re-wiring the entire
// datapath a third time by hand. The old version duplicated every connection
// here on top of Golden_Top.sv and Faulty_Top.sv -- three copies of the same
// wiring to keep in sync is exactly the kind of duplication that let the
// golden and faulty ALUs drift apart in the first place.
module Single_Cycle_Top_Comparison(
    input clk,
    input rst_n,
    output [31:0] PC_Golden,
    output [31:0] Result_Golden,
    output [31:0] PC_Faulty,
    output [31:0] Result_Faulty
);

    Single_Cycle_Top golden_proc (
        .clk(clk),
        .rst_n(rst_n),
        .PC_Top_Out(PC_Golden),
        .Result_Out(Result_Golden)
    );

    Single_Cycle_Top_faulty faulty_proc (
        .clk(clk),
        .rst_n(rst_n),
        .PC_Top_Out(PC_Faulty),
        .Result_Out(Result_Faulty)
    );

endmodule
