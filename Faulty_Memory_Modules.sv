// ------------------- Faulty Processor Memory Modules -------------------

`timescale 1ns/1ps

// ------------------------- Data Memory (Faulty) -------------------------
module Data_Memory_faulty(clk, rst, WE, WD, A, RD);
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

// ---------------------- Instruction Memory (Faulty) ----------------------
module Instruction_Memory_faulty(rst, A, RD);
    input rst;
    input [31:0] A;
    output [31:0] RD;

    reg [31:0] mem [1023:0];
    reg [31:0] RD_out;

    always @(A) begin
        RD_out = mem[A[31:2]];
        RD_out[0] = 1'b0;  // Simulate bit-level stuck-at-0 fault
    end

    assign RD = (~rst) ? 32'd0 : RD_out;

    initial begin
        mem[0] = 32'h0062E233;
        mem[1] = 32'h00B67433;
        mem[2] = 32'h00B60933;
        mem[3] = 32'h41390433;
        mem[4] = 32'h015A4433;
        mem[5] = 32'h017B2433;
    end
endmodule

// ------------------------- Program Counter (Faulty) -------------------------
module PC_Module_faulty(clk, rst, PC, PC_Next);
    input clk, rst;
    input [31:0] PC_Next;
    output [31:0] PC;
    reg [31:0] PC;

    always @(posedge clk) begin
        if (~rst)
            PC <= {32{1'b0}};
        else
            PC <= PC_Next;
    end
endmodule

// ------------------------- Register File (Faulty) -------------------------
module Register_File_faulty(clk,rst,WE3,WD3,A1,A2,A3,RD1,RD2);
    input clk,rst,WE3;
    input [4:0]A1,A2,A3;
    input [31:0]WD3;
    output [31:0]RD1,RD2;

    reg [31:0] reg_file [31:0];

    always @ (posedge clk) begin
        if(WE3)
            reg_file[A3] <= WD3;
    end

    assign RD1 = (~rst) ? 32'd0 : reg_file[A1];
    assign RD2 = (~rst) ? 32'd0 : reg_file[A2];

    initial begin
        reg_file[5] = 32'h5;
        reg_file[6] = 32'h4;
        reg_file[11] = 32'h3;
        reg_file[12] = 32'h2;
        reg_file[18] = 32'h5;
        reg_file[19] = 32'h5;
        reg_file[20] = 32'h8;
        reg_file[21] = 32'h9;
        reg_file[22] = 32'h1;
        reg_file[23] = 32'h2;
    end
endmodule

// ------------------------- Sign Extend (Faulty) -------------------------
module Sign_Extend_faulty(In,Imm_Ext,ImmSrc);
    input [31:0]In;
    input ImmSrc;
    output [31:0]Imm_Ext;

    assign Imm_Ext = (ImmSrc == 1'b1) ? {{20{In[31]}},In[31:25],In[11:7]} :
                                        {{20{In[31]}},In[31:20]};
endmodule
