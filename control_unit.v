module control_unit(

    input  [6:0] op,
    input        op5,
    input  [2:0] funct3,
    input        funct7,

    output       regwrite,
    output       memwrite,
    output       resultsrc,
    output       alusrc,
    output [1:0] immsrc,
    output       pcsrc,
    output [2:0] ALUctrl

);

wire [1:0] ALUop;

main_decoder md(

    .op(op),
    .regwrite(regwrite),
    .memwrite(memwrite),
    .resultsrc(resultsrc),
    .alusrc(alusrc),
    .immsrc(immsrc),
    .ALUop(ALUop),
    .branch(pcsrc)

);

alu_decoder ad(

    .ALUop(ALUop),
    .op5(op5),
    .funct3(funct3),
    .funct7(funct7),
    .ALUctrl(ALUctrl)

);

endmodule