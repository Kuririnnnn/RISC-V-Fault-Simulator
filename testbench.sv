`timescale 1ns/1ps
module tb_Processor_Comparison;

    reg clk;
    reg rst;

    wire [31:0] golden_PC, golden_Result;
    wire [31:0] faulty_PC, faulty_Result;

    wire fault_detected;
    reg [7:0] fault_detected_text;  // 8-bit for "YES" / "NO"

    assign fault_detected = (golden_Result !== faulty_Result);

    // Update the fault text depending on fault_detected signal
    always @(*) begin
        if (fault_detected)
            fault_detected_text = "Y"; // Just showing 'Y' (YES) because $monitor can't handle full strings easily
        else
            fault_detected_text = "N"; // 'N' for NO
    end

    // Instantiate the Golden Processor
    Single_Cycle_Top golden_proc (
        .clk(clk),
        .rst_n(rst),
        .PC_Top_Out(golden_PC),
        .Result_Out(golden_Result)
    );

    // Instantiate the Faulty Processor
    Single_Cycle_Top_faulty faulty_proc (
        .clk(clk),
        .rst_n(rst),
        .PC_Top_Out(faulty_PC),
        .Result_Out(faulty_Result)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simulation sequence
    initial begin
        rst = 0;
        #10 rst = 1;
        #110 $finish;
    end

    // Monitor outputs
    initial begin
        $display("Time\tGolden PC\tGolden Result\tFaulty PC\tFaulty Result\tFault Detected");
        $monitor("%0t\t%h\t%h\t%h\t%h\t%c", 
                 $time, 
                 golden_PC, 
                 golden_Result, 
                 faulty_PC, 
                 faulty_Result, 
                 fault_detected_text);
    end
  	initial begin
      $dumpfile("dump.vcd");
      $dumpvars(0, tb_Processor_Comparison);
    end

endmodule
