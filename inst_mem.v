module inst_mem(A,rst,RD);
input [31:0] A;
input rst;
output [31:0] RD;

reg [31:0] Mem [1023:0];


initial begin
    $readmemh("program.mem",Mem);
end

assign RD = (rst==1'b0)?32'h00000000: Mem[A[31:2]];



endmodule
