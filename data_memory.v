module data_memory (A,WD,WE,clk,RD);

input [31:0] A,WD;
input WE,clk;
output [31:0] RD;
reg [31:0] data_mem [1023:0]; // 4k memory locations

initial begin
    data_mem[0] = 32'h12345678;
    data_mem[1] = 32'hAAAAAAAA;
    data_mem[2] = 32'h55555555;
    data_mem[3] = 32'hDEADBEEF;
end
assign RD = (WE==1'b0) ? data_mem[A[31:2]]:32'h00000000; // read data from memory


// write 
always @(posedge clk)
if (WE)
begin 
    data_mem[A[31:2]] <= WD; // write data to memory
end

endmodule