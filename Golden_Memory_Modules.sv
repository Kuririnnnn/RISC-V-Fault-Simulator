// -------------- Golden Processor Memory Modules --------------
`timescale 1ns/1ps

// ------------------------ Data Memory ------------------------
module Data_Memory #(parameter MEM_DEPTH = 1024) (clk, rst_n, WE, WD, A, RD);
    input clk, rst_n, WE;
    input [31:0] A, WD;
    output [31:0] RD;

    reg [31:0] mem [MEM_DEPTH-1:0];

    always @(posedge clk) begin
        if (WE)
            mem[A] <= WD;
    end

    assign RD = (~rst_n) ? 32'd0 : mem[A];

    initial begin
        mem[28] = 32'h00000020;
    end
endmodule

// --------------------- Instruction Memory ---------------------
module Instruction_Memory #(parameter MEM_DEPTH = 1024) (rst_n, A, RD);
    input rst_n;
    input [31:0] A;
    output [31:0] RD;

    reg [31:0] mem [MEM_DEPTH-1:0];

    assign RD = (~rst_n) ? 32'd0 : mem[A[31:2]];

    initial begin
        mem[0] = 32'h0062E233; // OR X4, X5, X6
        mem[1] = 32'h00B67433; // AND X8, X12, X11
        mem[2] = 32'h00B60933; // ADD X8, X12, X11
        mem[3] = 32'h41390433; // SUB X8, X18, X19
        mem[4] = 32'h015A4433; // XOR X8, X21, X20
        mem[5] = 32'h017B2433; // SLT X8, X23, X22
        mem[6] = 32'h01390463; // BEQ X18, X19, +8   (x18==x19==5, always taken)
        mem[7] = 32'h01390433; // ADD X8, X18, X19   (canary: should be SKIPPED -- would give 10)
        mem[8]  = 32'h015A7433; // AND X8, X20, X21   (BEQ branch target: x20=8,x21=9 -> 8)
        mem[9]  = 32'h015A1463; // BNE X20, X21, +8   (x20=8 != x21=9, always taken)
        mem[10] = 32'h015A6433; // OR  X8, X20, X21   (canary: should be SKIPPED -- would give 9)
        mem[11] = 32'h017B4433; // XOR X8, X22, X23   (BNE branch target: x22=1,x23=2 -> 3)
        // Trailing NOPs (real RISC-V encoding: ADDI x0,x0,0) so the run
        // doesn't fetch uninitialized ('x') memory once the branch/fall-
        // through paths run past the end of the program. This design
        // doesn't decode I-type ALU-immediate ops, but that's harmless
        // here: opcode 0010011 falls through every decoder's default
        // case, giving RegWrite=0, MemWrite=0, Branch=0 -- i.e. it's an
        // effective no-op even though it isn't "properly" decoded.
        mem[12] = 32'h00000013;
        mem[13] = 32'h00000013;
        mem[14] = 32'h00000013;
        mem[15] = 32'h00000013;
        mem[16] = 32'h00000013;
        mem[17] = 32'h00000013;
        mem[18] = 32'h00000013;
        mem[19] = 32'h00000013;
        mem[20] = 32'h00000013;
    end
endmodule

// ---------------------- Program Counter ----------------------
module PC_Module(clk, rst_n, PC, PC_Next);
    input clk, rst_n;
    input [31:0] PC_Next;
    output [31:0] PC;
    reg [31:0] PC;

    always @(posedge clk) begin
        if (~rst_n)
            PC <= 32'b0;
        else
            PC <= PC_Next;
    end
endmodule

// ----------------------- Register File -----------------------
module Register_File(clk,rst_n,WE3,WD3,A1,A2,A3,RD1,RD2);
    input clk,rst_n,WE3;
    input [4:0]A1,A2,A3;
    input [31:0]WD3;
    output [31:0]RD1,RD2;

    reg [31:0] Register [31:0];

    always @ (posedge clk) begin
        if(WE3)
            Register[A3] <= WD3;
    end

    assign RD1 = (~rst_n) ? 32'd0 : Register[A1];
    assign RD2 = (~rst_n) ? 32'd0 : Register[A2];

    initial begin
        Register[0]  = 32'h00000000; // x0 -- RISC-V requires this to always read as 0
        Register[5]  = 32'h00000005;
        Register[6]  = 32'h00000004;
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
// ImmSrc is now the full 2-bit code from Main_Decoder:
//   00 = I-type (loads)
//   01 = S-type (stores)
//   10 = B-type (branches) -- bits are scattered across the instruction
//        and the LSB is implicitly 0 (branch targets are always 2-byte aligned)
module Sign_Extend (In,Imm_Ext,ImmSrc);
    input [31:0]In;
    input [1:0]ImmSrc;
    output reg [31:0]Imm_Ext;

    always @(*) begin
        case (ImmSrc)
            2'b00:   Imm_Ext = {{20{In[31]}}, In[31:20]};
            2'b01:   Imm_Ext = {{20{In[31]}}, In[31:25], In[11:7]};
            2'b10:   Imm_Ext = {{19{In[31]}}, In[31], In[7], In[30:25], In[11:8], 1'b0};
            default: Imm_Ext = 32'b0;
        endcase
    end
endmodule
