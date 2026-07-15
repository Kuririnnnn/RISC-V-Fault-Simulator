// -------------- Golden Processor Datapath --------------
`timescale 1ns/1ps

// ------------------------- ALU -------------------------
module ALU(A,B,Result,ALUControl,OverFlow,Carry,Zero,Negative);
    input [31:0] A,B;
    input [2:0] ALUControl;
    output Carry, OverFlow, Zero, Negative;
    output [31:0] Result;

    wire Cout;
    wire [31:0] Sum;

    assign {Cout,Sum} = (ALUControl[0] == 1'b0) ? A + B : (A + ((~B)+1));

    assign Result = (ALUControl == 3'b000) ? Sum :
                    (ALUControl == 3'b001) ? Sum :
                    (ALUControl == 3'b010) ? A & B :
                    (ALUControl == 3'b011) ? A | B :
                    (ALUControl == 3'b101) ? {{31{1'b0}},(Sum[31])} :
                    (ALUControl == 3'b111) ? A ^ B : {32{1'b0}};

    assign OverFlow = ((Sum[31] ^ A[31]) & (~(ALUControl[0] ^ B[31] ^ A[31])) & (~ALUControl[1]));
    assign Carry = ((~ALUControl[1]) & Cout);
    assign Zero = (Result == 32'b0);   // was: &(~Result) -- identical result, clearer intent
    assign Negative = Result[31];
endmodule

// ---------------------- Control Unit ----------------------
// Main_Decoder / ALU_Decoder now live in Shared_Decoder_Modules.sv
// and are reused as-is by the faulty control unit too, since
// instruction decoding itself was never meant to be the fault.
module Control_Unit_Top(Op, RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, funct3, funct7, ALUControl);
    input [6:0] Op, funct7;
    input [2:0] funct3;
    output RegWrite, ALUSrc, MemWrite, ResultSrc, Branch;
    output [1:0] ImmSrc;
    output [2:0] ALUControl;
    wire [1:0] ALUOp;

    Main_Decoder main_decoder(
        .Op(Op),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );

    ALU_Decoder alu_decoder(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .op(Op),
        .ALUControl(ALUControl)
    );
endmodule
