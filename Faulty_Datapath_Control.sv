// ------------------- Faulty Processor Datapath ------------------

`timescale 1ns/1ps

// ------------------------- ALU (Faulty) -------------------------
module ALU_faulty (
    input clk,
    input rst,
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUControl,
    output reg [31:0] Result,
    output reg OverFlow,
    output reg Carry,
    output reg Zero,
    output reg Negative
);
    reg [2:0] ALUControl_effective;
    reg [3:0] fault_counter;
    reg fault_active;

    reg [31:0] Result_internal;    // Intermediate result before delay fault

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            fault_counter <= 0;
            fault_active <= 0;
        end else begin
            if (fault_counter < 3) begin
                fault_counter <= fault_counter + 1;
            end else begin
                fault_active <= 1;
            end
        end
    end

    always @(*) begin
        if (fault_active)
            ALUControl_effective = 3'b000; // Force AND operation when fault
        else
            ALUControl_effective = ALUControl;

        case (ALUControl_effective)
            3'b000: Result_internal = A & B;
            3'b001: Result_internal = A | B;
            3'b010: Result_internal = A + B;
            3'b110: Result_internal = A - B;
            3'b111: Result_internal = (A < B) ? 32'b1 : 32'b0;
            3'b100: Result_internal = ~(A | B);
            default: Result_internal = 32'b0;
        endcase

        Zero = (Result_internal == 32'b0) ? 1'b1 : 1'b0;
        Negative = Result_internal[31];
        OverFlow = 1'b0;
        Carry = 1'b0;
    end

    // Delay fault injected here
    always @(posedge clk or negedge rst) begin
        if (!rst)
            Result <= 32'b0;
        else
            Result <= #3 Result_internal; // <- 3ns delay fault injected
    end

endmodule

// ---------------- Main Decoder (Faulty) ----------------
module Main_Decoder_faulty(Op,RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,ALUOp);
    input [6:0]Op;
    output RegWrite,ALUSrc,MemWrite,ResultSrc,Branch;
    output [1:0]ImmSrc,ALUOp;

    assign RegWrite = (Op == 7'b0000011 || Op == 7'b0110011) ? 1'b1 : 1'b0;
    assign ImmSrc = (Op == 7'b0100011) ? 2'b01 : (Op == 7'b1100011) ? 2'b10 : 2'b00;
    assign ALUSrc = (Op == 7'b0000011 || Op == 7'b0100011) ? 1'b1 : 1'b0;
    assign MemWrite = (Op == 7'b0100011) ? 1'b1 : 1'b0;
    assign ResultSrc = (Op == 7'b0000011) ? 1'b1 : 1'b0;
    assign Branch = (Op == 7'b1100011) ? 1'b1 : 1'b0;
    assign ALUOp = (Op == 7'b0110011) ? 2'b10 : (Op == 7'b1100011) ? 2'b01 : 2'b00;
endmodule

// ---------------- ALU Decoder (Faulty) ----------------
module ALU_Decoder_faulty(ALUOp,funct3,funct7,op,ALUControl);
    input [1:0]ALUOp;
    input [2:0]funct3;
    input [6:0]funct7,op;
    output [2:0]ALUControl;

    assign ALUControl = (ALUOp == 2'b00) ? 3'b000 :
                        (ALUOp == 2'b01) ? 3'b001 :
                        ((ALUOp == 2'b10) && (funct3 == 3'b000) && ({op[5],funct7[5]} == 2'b11)) ? 3'b001 :
                        ((ALUOp == 2'b10) && (funct3 == 3'b000) && ({op[5],funct7[5]} != 2'b11)) ? 3'b000 :
                        ((ALUOp == 2'b10) && (funct3 == 3'b010)) ? 3'b101 :
                        ((ALUOp == 2'b10) && (funct3 == 3'b110)) ? 3'b011 :
                        ((ALUOp == 2'b10) && (funct3 == 3'b111)) ? 3'b010 :
                        ((ALUOp == 2'b10) && (funct3 == 3'b100)) ? 3'b111 : 3'b000;
endmodule

// ---------------- Control Unit (Faulty) ----------------
module Control_Unit_Top_faulty(Op,RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,funct3,funct7,ALUControl);
    input [6:0]Op,funct7;
    input [2:0]funct3;
    output RegWrite,ALUSrc,MemWrite,ResultSrc,Branch;
    output [1:0]ImmSrc;
    output [2:0]ALUControl;

    wire [1:0]ALUOp;

    Main_Decoder_faulty main_decoder(
        .Op(Op),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .MemWrite(MemWrite),
        .ResultSrc(ResultSrc),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp)
    );

    ALU_Decoder_faulty alu_decoder(
        .ALUOp(ALUOp),
        .funct3(funct3),
        .funct7(funct7),
        .op(Op),
        .ALUControl(ALUControl)
    );
endmodule
