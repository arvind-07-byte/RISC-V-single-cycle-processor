module alu_decoder(ALUop,op5, funct3, funct7, ALUctrl);

input [1:0] ALUop;
input [2:0] funct3; 
input funct7, op5;
output [2:0] ALUctrl;



wire [1:0] concat;
assign concat = {op5, funct7};

assign ALUctrl =

(ALUop==2'b00) ? 3'b000 :          // ADD (lw/sw)

(ALUop==2'b01) ? 3'b001 :          // SUB (beq)

(ALUop==2'b10 && funct3==3'b000 && concat==2'b10) ? 3'b000 : // ADD

(ALUop==2'b10 && funct3==3'b000 && concat==2'b11) ? 3'b001 : // SUB

(ALUop==2'b10 && funct3==3'b111) ? 3'b010 : // AND

(ALUop==2'b10 && funct3==3'b110) ? 3'b011 : // OR

(ALUop==2'b10 && funct3==3'b010) ? 3'b101 : // SLT

3'b000;
 
endmodule