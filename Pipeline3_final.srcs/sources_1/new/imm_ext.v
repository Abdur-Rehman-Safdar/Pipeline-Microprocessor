`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 04:14:25 PM
// Design Name: 
// Module Name: imm_ext
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


module imm_ext(input [1:0]Imm_Src,input [31:0]instruction,output reg [31:0]imm_out );

wire[6:0] opcode=instruction[6:0];
//wire [11:0]imm_load=instruction[31:20];
reg [31:0]imm_i,imm_s,imm_b,imm_j;
always@(*)
    begin
        imm_i = 32'b0;
        imm_s = 32'b0;
        imm_b = 32'b0;
        imm_j= 32'b0;
        
        case(opcode)
        7'b0010011,7'b0000011: imm_i = {{20{instruction[31]}}, instruction[31:20]}; // I-Type (addi)
        7'b0100011: imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S-Type (sw)
        7'b1100011: imm_b = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0}; // B-Type (beq)
        7'b1101111 : imm_j = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0} ;
       
        default: begin
        imm_i=32'b0;
        imm_s=32'b0;
        imm_b=32'b0;
        imm_j=32'b0;
        end
        endcase
    end
    
always@(*)
    begin
        case(Imm_Src)
        2'b00 : imm_out = imm_i;
        2'b01: imm_out = imm_s;
        2'b10: imm_out = imm_b; 
        2'b11: imm_out = imm_j; 
        default: imm_out=32'b0;
        endcase
    end
       
    
    
    
endmodule
