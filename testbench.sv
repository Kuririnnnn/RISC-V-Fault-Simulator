`timescale 1ns/1ps
module tb_Processor_Comparison;
    reg clk;
    reg rst;
    wire [31:0] golden_PC, golden_Result;
    wire [31:0] faulty_PC, faulty_Result;
    wire fault_detected;
    reg [7:0] fault_char;

    assign fault_detected = (golden_Result !== faulty_Result);

    always @(*) begin
        fault_char = fault_detected ? "Y" : "N";
    end

    Single_Cycle_Top golden_proc (
        .clk(clk),
        .rst_n(rst),
        .PC_Top_Out(golden_PC),
        .Result_Out(golden_Result)
    );

    Single_Cycle_Top_faulty faulty_proc (
        .clk(clk),
        .rst_n(rst),
        .PC_Top_Out(faulty_PC),
        .Result_Out(faulty_Result)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_Processor_Comparison);
    end

    initial begin
        rst = 0;
        #10 rst = 1;
        #170 $finish;
    end

    initial begin
        $display("%-10s %-12s %-14s %-12s %-14s %-14s",
                  "Time", "Golden PC", "Golden Result", "Faulty PC", "Faulty Result", "Fault Detected");
        $monitor("%-10d %-12h %-14h %-12h %-14h %-14c",
                  $time, golden_PC, golden_Result, faulty_PC, faulty_Result, fault_char);
    end
endmodule
