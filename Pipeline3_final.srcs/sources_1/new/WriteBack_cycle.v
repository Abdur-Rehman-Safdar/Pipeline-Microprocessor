`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 09:16:34 PM
// Design Name: 
// Module Name: WriteBack_cycle
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


module WriteBack_cycle(input clk,rst,
input RegWrite_W_in,
input [1:0]ResultSrc_W,
input [31:0]ALUResult_W,
input[31:0]ReadData_W,
input [4:0]RD_W_in,
input [31:0] PC_Plus4_W,
output  [31:0]Result_W,
output  RegWrite_W_out,
output  [4:0]RD_W_out

);

//wire [31:0] Result_comb;

mux3_1 ResultMux(ALUResult_W, ReadData_W, PC_Plus4_W, ResultSrc_W, Result_W);

assign RD_W_out = RD_W_in;

assign RegWrite_W_out = RegWrite_W_in;

//always @(posedge clk) begin
//        if (rst) begin
//            Result_W <= 32'b0;
//            RegWrite_W_out <= 1'b0;
//            RD_W_out <= 5'b0;
//        end 
//        else begin
//            Result_W <= Result_comb;
//            RegWrite_W_out <= RegWrite_W_in;
//            RD_W_out <= RD_W_in;
//        end
//    end


endmodule
