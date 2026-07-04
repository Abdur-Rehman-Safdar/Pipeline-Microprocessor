`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 06:24:29 PM
// Design Name: 
// Module Name: main_decoder_tb
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


module main_decoder_tb();

reg [31:0] instruction;
wire RegWrite;
wire [1:0] ImmSrc;
wire       ALUSrc;
wire    MemWrite;
wire    ResultSrc; // Changed to 2-bit to support saving PC+4
wire   Branch;
wire     Jump;
wire [2:0]alu_control;
    
main_decoder MainDecoder( instruction,RegWrite, ImmSrc,  ALUSrc, MemWrite,  ResultSrc, Branch, Jump,alu_control);

initial begin
   
   //1. I-Type L7:lw x6, -4(x9)
    instruction = 32'hFFC4A303; 
    #10;
    
    // 2. S-Type (sw x6, 32(x9)) -> Opcode: 7'b0100011
   
    instruction = 32'h0064A423; // Valid sw instruction
    #10;
    
    // 3. B-Type (bne x9, x10, label) -> Opcode: 7'b1100011
    
    instruction = 32'hFE4208E3; // Valid bne instruction
    #10;
    $finish;
end

endmodule
