
module single_cycle_top(rst,clk);

input rst , clk;

wire [31:0] PC_Top, PCplus4, PCbranch, PC_next,
 RD_instr,RD1_Top,
 IMM_EXT_Top,
 ReadData,ALUResult;

wire regwrite;
wire memwrite;
wire resultsrc;
wire alusrc;
wire pcsrc;

wire [1:0] immsrc;
wire [31:0] RD2_Top;
wire [2:0] ALU_control_top;

wire [31:0] SrcB;
assign SrcB = (alusrc) ? IMM_EXT_Top : RD2_Top;

wire [31:0] Result;
assign Result = (resultsrc) ? ReadData : ALUResult;

wire zero;
assign PC_next = (pcsrc && zero) ? PCbranch : PCplus4;

pc u1(.clk(clk),
.rst(rst),
.PC_next(PC_next),.PC(PC_Top));


pc_adder u8(.a(PC_Top),.b(32'd4),.c(PCplus4));
pc_adder u9(.a(PC_Top),.b(IMM_EXT_Top),.c(PCbranch));

inst_mem u2(.A(PC_Top),
.RD(RD_instr),
.rst(rst));

sign_extend u4(
    .In(RD_instr),
    .ImmSrc(immsrc),
    .Imm_Ext(IMM_EXT_Top)
);


Reg_file u3 (.clk(clk),
.rst(rst),
.A1(RD_instr[19:15]),
.A2(RD_instr[24:20]),
.A3(RD_instr[11:7]),
.WD3(Result),.WE3(regwrite),.RD1(RD1_Top),.RD2(RD2_Top));


ALU U5(

    .A(RD1_Top),

    .B(SrcB),      

    .ALUControl(ALU_control_top),

    .Result(ALUResult),

    .z(zero),

    .n(),

    .c(),

    .v()

);



control_unit CU
(

    .op(RD_instr[6:0]),

    .op5(RD_instr[5]),

    .funct3(RD_instr[14:12]),

    .funct7(RD_instr[30]),

    .regwrite(regwrite),

    .memwrite(memwrite),

    .resultsrc(resultsrc),

    .alusrc(alusrc),

    .immsrc(immsrc),

    .pcsrc(pcsrc),

    .ALUctrl(ALU_control_top)

);

data_memory u7(
    .clk(clk),
    .A(ALUResult),
    .WD(RD2_Top),
    .WE(memwrite),
    .RD(ReadData));


endmodule
