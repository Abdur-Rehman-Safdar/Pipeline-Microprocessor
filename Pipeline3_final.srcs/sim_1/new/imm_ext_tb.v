`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 04:48:47 PM
// Design Name: 
// Module Name: imm_ext_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module imm_ext_tb();
reg[1:0]Imm_Src;
reg [31:0]instruction;
wire [31:0]imm_out;

imm_ext ImmExt(Imm_Src,instruction,imm_out );

initial begin

    //1. I-Type L7:lw x6, -4(x9)
    Imm_Src = 2'b00;
    instruction = 32'hFFC4A303; 
    #10;
    
    // 2. S-Type (sw x6, 32(x9)) -> Opcode: 7'b0100011
    Imm_Src = 2'b01;
    instruction = 32'h0064A423; // Valid sw instruction
    #10;
    
    // 3. B-Type (bne x9, x10, label) -> Opcode: 7'b1100011
    Imm_Src = 2'b10;
    instruction = 32'hFE4208E3; // Valid bne instruction
    #10;
    $finish;
end

endmodule
