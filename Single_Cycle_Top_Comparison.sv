// ---------------- Top Module (Comparison of Golden and Faulty) ----------------

`include "Basic_Helper_Modules.sv"
`include "Golden_Datapath_Control.sv"
`include "Golden_Memory_Modules.sv"
`include "Faulty_Datapath_Control.sv"
`include "Faulty_Memory_Modules.sv"
`include "Golden_Top.sv"
`include "Faulty_Top.sv"

`timescale 1ns/1ps

module Single_Cycle_Top_Comparison(
    input clk,
    input rst,
    output [31:0] PC_Golden,
    output [31:0] Result_Golden,
    output [31:0] PC_Faulty,
    output [31:0] Result_Faulty
);

    wire [31:0] PC_G, RD_Instr_G, RD1_G, RD2_G, Imm_Ext_G, ALUResult_G, ReadData_G, PCPlus4_G, SrcB_G, Result_G;
    wire RegWrite_G, MemWrite_G, ALUSrc_G, ResultSrc_G;
    wire [1:0] ImmSrc_G;
    wire [2:0] ALUControl_G;

    wire [31:0] PC_F, RD_Instr_F, RD1_F, RD2_F, Imm_Ext_F, ALUResult_F, ReadData_F, PCPlus4_F, SrcB_F, Result_F;
    wire RegWrite_F, MemWrite_F, ALUSrc_F, ResultSrc_F;
    wire [1:0] ImmSrc_F;
    wire [2:0] ALUControl_F;

    // Assign outputs
    assign PC_Golden = PC_G;
    assign Result_Golden = Result_G;
    assign PC_Faulty = PC_F;
    assign Result_Faulty = Result_F;

    // Golden processor
    PC_Module PC_Module_Golden(
        .clk(clk),
        .rst(rst),
        .PC(PC_G),
        .PC_Next(PCPlus4_G)
    );

    PC_Adder PC_Adder_G(
        .a(PC_G),
        .b(32'd4),
        .c(PCPlus4_G)
    );

    Instruction_Memory Instruction_Memory_G(
        .rst(rst),
        .A(PC_G),
        .RD(RD_Instr_G)
    );

    Register_File Register_File_G(
        .clk(clk),
        .rst(rst),
        .WE3(RegWrite_G),
        .WD3(Result_G),
        .A1(RD_Instr_G[19:15]),
        .A2(RD_Instr_G[24:20]),
        .A3(RD_Instr_G[11:7]),
        .RD1(RD1_G),
        .RD2(RD2_G)
    );

    Sign_Extend Sign_Extend_G(
        .In(RD_Instr_G),
        .ImmSrc(ImmSrc_G[0]),
        .Imm_Ext(Imm_Ext_G)
    );

    Mux Mux_Register_to_ALU_G(
        .a(RD2_G),
        .b(Imm_Ext_G),
        .s(ALUSrc_G),
        .c(SrcB_G)
    );

    ALU ALU_G(
        .A(RD1_G),
        .B(SrcB_G),
        .Result(ALUResult_G),
        .ALUControl(ALUControl_G),
        .OverFlow(),
        .Carry(),
        .Zero(),
        .Negative()
    );

    Control_Unit_Top Control_Unit_Top_G(
        .Op(RD_Instr_G[6:0]),
        .RegWrite(RegWrite_G),
        .ImmSrc(ImmSrc_G),
        .ALUSrc(ALUSrc_G),
        .MemWrite(MemWrite_G),
        .ResultSrc(ResultSrc_G),
        .Branch(),
        .funct3(RD_Instr_G[14:12]),
        .funct7(RD_Instr_G[31:25]),
        .ALUControl(ALUControl_G)
    );

    Data_Memory Data_Memory_G(
        .clk(clk),
        .rst(rst),
        .WE(MemWrite_G),
        .WD(RD2_G),
        .A(ALUResult_G),
        .RD(ReadData_G)
    );

    Mux Mux_DataMemory_to_Register_G(
        .a(ALUResult_G),
        .b(ReadData_G),
        .s(ResultSrc_G),
        .c(Result_G)
    );

    // Faulty processor
    PC_Module_faulty PC_Module_Faulty(
        .clk(clk),
        .rst(rst),
        .PC(PC_F),
        .PC_Next(PCPlus4_F)
    );

    PC_Adder PC_Adder_F(
        .a(PC_F),
        .b(32'd4),
        .c(PCPlus4_F)
    );

    Instruction_Memory_faulty Instruction_Memory_F(
        .rst(rst),
        .A(PC_F),
        .RD(RD_Instr_F)
    );

    Register_File_faulty Register_File_F(
        .clk(clk),
        .rst(rst),
        .WE3(RegWrite_F),
        .WD3(Result_F),
        .A1(RD_Instr_F[19:15]),
        .A2(RD_Instr_F[24:20]),
        .A3(RD_Instr_F[11:7]),
        .RD1(RD1_F),
        .RD2(RD2_F)
    );

    Sign_Extend_faulty Sign_Extend_F(
        .In(RD_Instr_F),
        .ImmSrc(ImmSrc_F[0]),
        .Imm_Ext(Imm_Ext_F)
    );

    Mux Mux_Register_to_ALU_F(
        .a(RD2_F),
        .b(Imm_Ext_F),
        .s(ALUSrc_F),
        .c(SrcB_F)
    );

    ALU_faulty ALU_F(
        .clk(clk),
        .rst(rst),
        .A(RD1_F),
        .B(SrcB_F),
        .Result(ALUResult_F),
        .ALUControl(ALUControl_F),
        .OverFlow(),
        .Carry(),
        .Zero(),
        .Negative()
    );

    Control_Unit_Top_faulty Control_Unit_Top_F(
        .Op(RD_Instr_F[6:0]),
        .RegWrite(RegWrite_F),
        .ImmSrc(ImmSrc_F),
        .ALUSrc(ALUSrc_F),
        .MemWrite(MemWrite_F),
        .ResultSrc(ResultSrc_F),
        .Branch(),
        .funct3(RD_Instr_F[14:12]),
        .funct7(RD_Instr_F[31:25]),
        .ALUControl(ALUControl_F)
    );

    Data_Memory_faulty Data_Memory_F(
        .clk(clk),
        .rst(rst),
        .WE(MemWrite_F),
        .WD(RD2_F),
        .A(ALUResult_F),
        .RD(ReadData_F)
    );

    Mux Mux_DataMemory_to_Register_F(
        .a(ALUResult_F),
        .b(ReadData_F),
        .s(ResultSrc_F),
        .c(Result_F)
    );

endmodule

