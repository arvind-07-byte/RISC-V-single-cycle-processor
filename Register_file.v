module Reg_file (A1,A2,A3,WD3,WE3,rst,clk,RD1,RD2);
input [4:0] A1,A2,A3;
input [31:0] WD3;
input WE3,rst,clk;
output [31:0] RD1,RD2;

// create memory array 32x32
reg [31:0] Reg_Mem [31:0];

//read functionality
assign RD1= (!rst) ? 32'b0 : Reg_Mem[A1];
assign RD2 = (!rst) ? 32'b0 : Reg_Mem[A2];


always @(posedge clk)
begin
   
   if (WE3 && (A3 != 5'd0))
    Reg_Mem[A3] <= WD3; 
end

endmodule