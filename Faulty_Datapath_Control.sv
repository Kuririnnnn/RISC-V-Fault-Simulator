// ------------------- Faulty Processor Datapath ------------------
`timescale 1ns/1ps

// ------------------------- ALU (Faulty) -------------------------
module ALU_faulty (
    input clk,
    input rst_n,
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
    reg [31:0] Result_internal; // Intermediate result before delay fault
    wire [31:0] SLT_Diff = A - B; // named signal so we can bit-select [31] on it

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
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
            ALUControl_effective = 3'b000; // Force ADD operation when fault
        else
            ALUControl_effective = ALUControl;

        // Encoding matches Golden_ALU / ALU_Decoder
        // (000=ADD, 001=SUB, 010=AND, 011=OR, 101=SLT, 111=XOR).
        case (ALUControl_effective)
            3'b000: Result_internal = A + B;                     // ADD
            3'b001: Result_internal = A + ((~B) + 1);             // SUB (shared-adder style)
            3'b010: Result_internal = A & B;                      // AND
            3'b011: Result_internal = A | B;                      // OR
            3'b101: Result_internal = {31'b0,
                        (A[31] ^ B[31]) ? A[31] : SLT_Diff[31]};   // SLT, overflow-safe
            3'b111: Result_internal = A ^ B;                      // XOR
            default: Result_internal = 32'b0;
        endcase

        Zero = (Result_internal == 32'b0) ? 1'b1 : 1'b0;
        Negative = Result_internal[31];
        OverFlow = 1'b0;
        Carry = 1'b0;
    end

    // Delay fault injected here
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            Result <= 32'b0;
        else
            Result <= #3 Result_internal; // <- 3ns delay fault injected
    end

endmodule

// ---------------- Control Unit (Faulty) ----------------
// Reuses the shared Main_Decoder / ALU_Decoder from
// Shared_Decoder_Modules.sv -- decoding itself isn't faulty,
// only the ALU and memories are.
module Control_Unit_Top_faulty(Op,RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,funct3,funct7,ALUControl);
    input [6:0]Op,funct7;
    input [2:0]funct3;
    output RegWrite,ALUSrc,MemWrite,ResultSrc,Branch;
    output [1:0]ImmSrc;
    output [2:0]ALUControl;
    wire [1:0]ALUOp;

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
