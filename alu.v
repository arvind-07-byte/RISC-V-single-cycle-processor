module ALU(
    input [31:0] A,
    input [31:0] B,
    input [2:0] ALUControl,
    output [31:0] Result,
    output n,z,c,v// flags
);

wire [31:0] b_not;
wire [31:0] b_and_a;
wire[31:0] b_or_a;

wire [31:0]mux1,mux2;
wire [31:0] slt;
wire [31:0] sum;
wire cout; // carry out 
// logic for ALU operations
assign b_not = ~B;

assign b_and_a = A & B;
assign b_or_a = A | B;

assign mux1=(ALUControl[0] == 1'b0)? B:b_not;  // gives b or b_not based on ALUControl[0] value 

assign {cout, sum} = A + mux1+ ALUControl[0];

assign mux2 = (ALUControl[2:0] == 3'b000)? sum :  // 4x1 mux to select the output based on ALUControl[1:0] value
              (ALUControl[2:0]==3'b001)?sum:
              (ALUControl[2:0]==3'b010)?b_and_a:
             (ALUControl[2:0]==3'b011)?b_or_a:
             (ALUControl[2:0]==3'b101)?slt:32'h00000000; // default case


// zero extension 
assign slt = {31'd0,sum[31]};
assign Result = mux2;

// zero flag 
assign z = &(~Result);  // reduction AND of the negated Result to check if all bits are zero
// negative flag
assign n = Result[31];  // sign bit
// carry flag
assign c = cout & (~ALUControl[1]);// combine carry out with ALUControl[1] to determine if carry flag should be set
// overflow flag
assign v =(~ALUControl[1]) & (A[31]^sum[31]) & (~(A[31]^B[31]^ALUControl[0])); // overflow occurs when the sign of the result is different from the sign of the inputs

endmodule 