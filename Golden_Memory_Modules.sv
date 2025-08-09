// -------------- Golden Processor Memory Modules --------------

`timescale 1ns/1ps

// ------------------------ Data Memory ------------------------
module Data_Memory(clk, rst, WE, WD, A, RD);
    input clk, rst, WE;
    input [31:0] A, WD;
    output [31:0] RD;

    reg [31:0] mem [1023:0];

    always @(posedge clk) begin
        if (WE)
            mem[A] <= WD;
    end

    assign RD = (~rst) ? 32'd0 : mem[A];

    initial begin
        mem[28] = 32'h00000020;
    end
endmodule

// --------------------- Instruction Memory ---------------------
module Instruction_Memory(rst, A, RD);
    input rst;
    input [31:0] A;
    output [31:0] RD;

    reg [31:0] mem [1023:0];

    assign RD = (~rst) ? 32'd0 : mem[A[31:2]];

    initial begin
        mem[0] = 32'h0062E233;   // OR X4, X5, X6
        mem[1] = 32'h00B67433;   // AND X8, X12, X11
        mem[2] = 32'h00B60933;   // ADD X8, X12, X11
        mem[3] = 32'h41390433;   // SUB X8, X18, X19
        mem[4] = 32'h015A4433;   // XOR X8, X21, X20
        mem[5] = 32'h017B2433;   // SLT X8, X23, X22
    end
endmodule

// ---------------------- Program Counter ----------------------
module PC_Module(clk, rst, PC, PC_Next);
    input clk, rst;
    input [31:0] PC_Next;
    output [31:0] PC;
    reg [31:0] PC;

    always @(posedge clk) begin
        if (~rst)
            PC <= 32'b0;
        else
            PC <= PC_Next;
    end
endmodule

// ----------------------- Regidter File -----------------------
module Register_File(clk,rst,WE3,WD3,A1,A2,A3,RD1,RD2);

    input clk,rst,WE3;
    input [4:0]A1,A2,A3;
    input [31:0]WD3;
    output [31:0]RD1,RD2;

    reg [31:0] Register [31:0];

    always @ (posedge clk)
    begin
        if(WE3)
            Register[A3] <= WD3;
    end

    assign RD1 = (~rst) ? 32'd0 : Register[A1];
    assign RD2 = (~rst) ? 32'd0 : Register[A2];

    initial begin
      Register[5] = 32'h00000005;
      Register[6] = 32'h00000004;
      Register[11] = 32'h00000003;
      Register[12] = 32'h00000002;
      Register[18] = 32'h00000005;
      Register[19] = 32'h00000005;
      Register[20] = 32'h00000008;
      Register[21] = 32'h00000009;
      Register[22] = 32'h00000001;
      Register[23] = 32'h00000002;
        
    end

endmodule

// ------------------------ Sign Extend ------------------------
module Sign_Extend (In,Imm_Ext,ImmSrc);

    input [31:0]In;
    input ImmSrc;
    output [31:0]Imm_Ext;

    assign Imm_Ext = (ImmSrc == 1'b1) ? ({{20{In[31]}},In[31:25],In[11:7]}):{{20{In[31]}},In[31:20]};
                                
endmodule
