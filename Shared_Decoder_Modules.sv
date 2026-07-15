// -------------------- Shared Decode Logic --------------------
// Instruction decoding is identical between the golden and faulty
// processors — only the ALU and memories are supposed to differ.
// Keeping one copy here (instead of a golden AND a _faulty copy)
// means the two control paths can no longer quietly drift apart,
// which is exactly what happened before with the ALUControl
// encoding mismatch between the golden and faulty ALUs.
`timescale 1ns/1ps

// --------------------- Main Decoder ---------------------
module Main_Decoder(Op,RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp);
    input [6:0] Op;
    output RegWrite, ALUSrc, MemWrite, ResultSrc, Branch;
    output [1:0] ImmSrc, ALUOp;

    assign RegWrite = (Op == 7'b0000011 | Op == 7'b0110011) ? 1'b1 : 1'b0;
    assign ImmSrc   = (Op == 7'b0100011) ? 2'b01 :
                       (Op == 7'b1100011) ? 2'b10 : 2'b00;
    assign ALUSrc   = (Op == 7'b0000011 | Op == 7'b0100011) ? 1'b1 : 1'b0;
    assign MemWrite = (Op == 7'b0100011) ? 1'b1 : 1'b0;
    assign ResultSrc = (Op == 7'b0000011) ? 1'b1 : 1'b0;
    assign Branch   = (Op == 7'b1100011) ? 1'b1 : 1'b0;
    assign ALUOp    = (Op == 7'b0110011) ? 2'b10 :
                       (Op == 7'b1100011) ? 2'b01 : 2'b00;
endmodule

// --------------------- ALU Decoder ---------------------
module ALU_Decoder(ALUOp, funct3, funct7, op, ALUControl);
    input [1:0] ALUOp;
    input [2:0] funct3;
    input [6:0] funct7, op;
    output [2:0] ALUControl;

    assign ALUControl = (ALUOp == 2'b00) ? 3'b000 :
                         (ALUOp == 2'b01) ? 3'b001 :
                         ((ALUOp == 2'b10) & (funct3 == 3'b000) & ({op[5],funct7[5]} == 2'b11)) ? 3'b001 :
                         ((ALUOp == 2'b10) & (funct3 == 3'b000) & ({op[5],funct7[5]} != 2'b11)) ? 3'b000 :
                         ((ALUOp == 2'b10) & (funct3 == 3'b010)) ? 3'b101 :
                         ((ALUOp == 2'b10) & (funct3 == 3'b110)) ? 3'b011 :
                         ((ALUOp == 2'b10) & (funct3 == 3'b111)) ? 3'b010 :
                         ((ALUOp == 2'b10) & (funct3 == 3'b100)) ? 3'b111 : 3'b000;
endmodule
