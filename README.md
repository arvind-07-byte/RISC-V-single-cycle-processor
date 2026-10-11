# 32-bit Single-Cycle RISC-V Processor

This repository contains the Verilog HDL implementation of a 32-bit single-cycle RISC-V processor microarchitecture. The processor is capable of executing a subset of the base RISC-V integer instruction set, including R-Type, I-Type, S-Type, and B-Type instructions.

## 🏗️ Architecture Overview

The processor datapath is built around four primary clocked state elements:

1. **Program Counter (PC):** A 32-bit register holding the address of the current instruction.


2. **Instruction Memory:** A single read-port memory that fetches the 32-bit instruction based on the PC address.


3. **Register File:** A 32-element $\times$ 32-bit memory block with two read ports and one write port. It contains 32 general-purpose registers (`x0` to `x31`).


4. **Data Memory:** A single read/write port memory for load and store operations.



## 🧠 Instruction Decoding & Control Unit

The Control Unit is responsible for deciphering the 32-bit machine language and is split into two combinational logic blocks: the **Main Decoder** and the **ALU Decoder**.

* **Main Decoder:** Examines the 7-bit `opcode` field (`Instr[6:0]`) to compute primary datapath control signals (`RegWrite`, `MemWrite`, `ALUSrc`, `ResultSrc`, `Branch`, `ImmSrc`) and a 2-bit `ALUOp` signal.


* **ALU Decoder:** Uses the 2-bit `ALUOp` signal from the Main Decoder, combined with the `funct3` (`Instr[14:12]`) and `funct7`/`op5` bits, to determine the 3-bit `ALUControl` signal that dictates the specific ALU operation.


* `ALUOp = 00`: Force addition (used for load/store memory address calculation).


* `ALUOp = 01`: Force subtraction (used for branch comparisons).


* `ALUOp = 10`: Look at `funct` fields to determine the specific R-type operation (add, sub, and, or, slt).





## 🛣️ Datapath Execution by Instruction Type

### 1. R-Type Instructions (e.g., `add`, `sub`, `and`, `or`, `slt`)

R-type (register-type) instructions operate on three registers: two source registers (`rs1`, `rs2`) and one destination register (`rd`). All R-type instructions share an opcode of `0110011` (or 33 in decimal).

* **Decoding:** The specific operation is determined by the `funct3` and `funct7` fields. The Main Decoder outputs `ALUOp = 10`, prompting the ALU Decoder to check the `funct` fields.


* **Datapath Flow:**
1. The Register File reads the values of `rs1` and `rs2` onto ports `RD1` and `RD2`.


2. The multiplexer controlled by `ALUSrc = 0` routes the `RD2` value directly into the ALU's second input (`SrcB`).


3. The ALU performs the computation based on `ALUControl`.


4. The multiplexer controlled by `ResultSrc = 0` routes the `ALUResult` back to the Register File's write data port (`WD3`), and `RegWrite = 1` writes the data to `rd` at the clock edge.





### 2. I-Type Instructions (e.g., `lw`, `addi`)

I-type (immediate-type) instructions use two register operands (`rs1`, `rd`) and a 12-bit immediate value.

* **Decoding:** For a Load Word (`lw`), the opcode is `0000011`. The Main Decoder sets `ALUOp = 00` to force the ALU to add.


* **Datapath Flow (Load Word):**
1. The base address is read from source register `rs1` via port `RD1`.


2. The 12-bit immediate (`Instr[31:20]`) is sign-extended to a 32-bit value (`ImmExt`).


3. `ALUSrc = 1` routes the `ImmExt` value into the ALU (`SrcB`).


4. The ALU adds the base address and the sign-extended offset (`ALUControl = 000`) to calculate the memory address (`ALUResult`).


5. Data Memory reads the value at `ALUResult` onto the `ReadData` bus.


6. `ResultSrc = 1` routes `ReadData` to the Register File, and `RegWrite = 1` writes it into `rd`.





### 3. S-Type Instructions (e.g., `sw`)

S-type (store-type) instructions write data from a register to memory using two source registers (`rs1` for base address, `rs2` for data) and a 12-bit immediate offset. The 12-bit immediate is split into two fields: `Instr[31:25]` and `Instr[11:7]`.

* **Decoding:** The opcode is `0100011`. The Main Decoder sets `MemWrite = 1`, `RegWrite = 0`, and `ALUOp = 00` (force addition).


* **Datapath Flow:**
1. The base address is read from `rs1` and the data to be stored is read from `rs2`.


2. The split 12-bit immediate is concatenated and sign-extended to 32 bits.


3. `ALUSrc = 1` routes the immediate to the ALU, which adds it to the base address to compute the destination memory address.


4. The data from `rs2` is routed to the Data Memory write port. Because `MemWrite = 1`, the data is written to memory at the clock edge.


5. `RegWrite = 0` ensures the Register File is not modified.





### 4. B-Type Instructions (e.g., `beq`)

B-type (branch-type) instructions compare two registers (`rs1`, `rs2`) and conditionally branch to a 12-bit immediate address offset.

* **Decoding:** The opcode is `1100011`. The Main Decoder asserts `Branch = 1` and sets `ALUOp = 01` to force the ALU to perform a subtraction.


* **Datapath Flow:**
1. The Register File reads `rs1` and `rs2`.
2. `ALUSrc = 0` routes `rs2` into the ALU, which subtracts `rs2` from `rs1`.


3. If the result is zero, the ALU sets the `Zero` flag to 1.


4. The `Branch` signal and the `Zero` flag are ANDed together to determine the `PCSrc` multiplexer. If true, the PC is updated with the branch target address (calculated by adding the sign-extended immediate to the current PC).





## ⚙️ Arithmetic Logic Unit (ALU)

The ALU executes computations on two 32-bit inputs (`A` and `B`) based on a 3-bit `ALUControl` signal. It supports the following core operations:

* `000`: Addition (`add`)
* `001`: Subtraction (`sub`)
* `010`: Bitwise AND (`and`)
* `011`: Bitwise OR (`or`)
* `101`: Set Less Than (`slt`)

The ALU is designed using a hardware divide-and-conquer approach with multiplexers, and outputs the primary 32-bit `Result` alongside 4 status flags: Negative (`N`), Zero (`Z`), Carry (`C`), and Overflow (`V`). For example, the `Zero` flag is set to logic-1 exclusively when all bits of the `Result` are 0.
