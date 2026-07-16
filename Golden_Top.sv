// ----------------------- Golden Processor Top -----------------------
`timescale 1ns/1ps

// ------------------------- Single Cycle Top -------------------------
module Single_Cycle_Top(
    input clk,
    input rst_n,
    output [31:0] PC_Top_Out,
    output [31:0] Result_Out
);

    wire [31:0] PC_Top, RD_Instr, RD1_Top, Imm_Ext_Top, ALUResult;
    wire [31:0] ReadData, PCPlus4, PCTarget, PCNext, RD2_Top, SrcB, Result;
    wire RegWrite, MemWrite, ALUSrc, ResultSrc, Branch, Zero, PCSrc;
    wire [1:0] ImmSrc;
    wire [2:0] ALUControl_Top;

    assign PC_Top_Out = PC_Top;
    assign Result_Out = Result;

    // Branch taken when the instruction is a branch AND the ALU's Zero
    // flag is set. Since ALU_Decoder always forces SUB (ALUControl=001)
    // for branch opcodes, Zero==1 means rs1==rs2 -- this implements BEQ.
    // Other branch types (BNE, BLT, ...) aren't decoded yet; see note
    // in Shared_Decoder_Modules.sv.
    assign PCSrc = Branch & Zero;

    PC_Module PC(
        .clk(clk),
        .rst_n(rst_n),
        .PC(PC_Top),
        .PC_Next(PCNext)
    );

    PC_Adder PC_Adder(
        .a(PC_Top),
        .b(32'd4),
        .c(PCPlus4)
    );

    PC_Adder PC_Adder_Branch(
        .a(PC_Top),
        .b(Imm_Ext_Top),
        .c(PCTarget)
    );

    Mux PC_Src_Mux(
        .a(PCPlus4),
        .b(PCTarget),
        .s(PCSrc),
        .c(PCNext)
    );

    Instruction_Memory Instruction_Memory(
        .rst_n(rst_n),
        .A(PC_Top),
        .RD(RD_Instr)
    );

    Register_File Register_File(
        .clk(clk),
        .rst_n(rst_n),
        .WE3(RegWrite),
        .WD3(Result),
        .A1(RD_Instr[19:15]),
        .A2(RD_Instr[24:20]),
        .A3(RD_Instr[11:7]),
        .RD1(RD1_Top),
        .RD2(RD2_Top)
    );

    Sign_Extend Sign_Extend(
        .In(RD_Instr),
        .ImmSrc(ImmSrc),
        .Imm_Ext(Imm_Ext_Top)
    );

    Mux Mux_Register_to_ALU(
        .a(RD2_Top),
        .b(Imm_Ext_Top),
        .s(ALUSrc),
        .c(SrcB)
    );

    ALU ALU(
        .A(RD1_Top),
        .B(SrcB),
        .Result(ALUResult),
        .ALUControl(ALUControl_Top),
        .OverFlow(),
        .Carry(),
        .Zero(Zero),
        .Negative()
    );

    Control_Unit_Top Control_Unit_Top(
        .Op(RD_Instr[6:0]),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .funct3(RD_Instr[14:12]),
        .funct7(RD_Instr[31:25]),
        .ALUControl(ALUControl_Top)
    );

    Data_Memory Data_Memory(
        .clk(clk),
        .rst_n(rst_n),
        .WE(MemWrite),
        .WD(RD2_Top),
        .A(ALUResult),
        .RD(ReadData)
    );

    Mux Mux_DataMemory_to_Register(
        .a(ALUResult),
        .b(ReadData),
        .s(ResultSrc),
        .c(Result)
    );

endmodule
