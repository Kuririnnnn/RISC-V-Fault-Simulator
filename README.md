# RISC-V-Fault-Simulator

## Introduction

Fault simulation is crucial for evaluating processor reliability by injecting faults and analysing their impact. This helps in designing more robust processors that can tolerate manufacturing defects and operational failures.

## Key Features

- **Single-Cycle RISC-V Processor Design** – Implements a single-cycle RV32I-subset datapath at the RTL level, supporting R-type ALU operations (ADD, SUB, AND, OR, XOR, SLT), branches (BEQ, BNE), and loads/stores (LW, SW).
- **Integrated Fault Simulation** – Two independent, concurrently-active faults:
  - A **3ns delay fault** on the faulty ALU's result register.
  - A **stuck-at-0 fault** on bit 0 of every instruction fetched by the faulty processor's instruction memory, which — among other effects — corrupts branch opcodes and load/store addresses, causing the faulty processor to miss taken branches and occasionally fetch from unintended memory locations.
- **Golden vs. Faulty Comparison** – Simultaneous execution of a fault-free ("golden") and a faulty processor, with per-cycle mismatch detection (`fault_detected`) between their program counters and ALU/memory results.
- **Shared Decode Logic** – Instruction decoding (`Main_Decoder`, `ALU_Decoder`) is implemented once and shared between the golden and faulty control paths, so only the modules that are actually meant to be faulty (ALU, instruction memory) can diverge from golden behavior.
- **RTL-Level Validation** – Functionality verified through a SystemVerilog testbench and simulation waveforms, including a hand-crafted test program that exercises R-type ALU ops, both branch types (with dedicated taken/not-taken and canary-skip checks), and a store/load round-trip through data memory.

## Supported Instructions

| Type | Instructions |
|---|---|
| R-type (ALU) | ADD, SUB, AND, OR, XOR, SLT |
| Branch | BEQ, BNE |
| Load/Store | LW, SW |

Not yet implemented: I-type ALU-immediate instructions (ADDI, ANDI, ...), BLT/BGE and unsigned branch variants, and jumps (JAL/JALR).

## Block Diagram

<img width="1080" height="677" alt="Image" src="https://github.com/user-attachments/assets/9425281b-e36a-4be3-be62-10617728648b" />

## Result

<img width="757" height="743" alt="Image" src="https://github.com/user-attachments/assets/357bedd6-9a6f-4fd1-a27f-6ccfc4fd536f" />

### Waveform

<img width="1816" height="375" alt="Image" src="https://github.com/user-attachments/assets/3fae3956-6500-4087-983d-fa1fbbc67fe8" />

## Tools Used

EDA Playground
