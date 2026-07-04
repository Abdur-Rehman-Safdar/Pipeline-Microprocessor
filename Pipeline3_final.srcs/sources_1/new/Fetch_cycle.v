`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 03:14:07 PM
// Design Name: 
// Module Name: Fetch_cycle
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


module Fetch_cycle(input clk, rst,Flush_D, Stall_F, Stall_D,
input [31:0] PC_TargetE,
input PCSrcE,
output reg[31:0]InstrD, PCD, PC_Plus4D);

wire [31:0]ReadData,PCF,PC_fetch,PC_Plus4;

//PCF = PCF' (next_pc),  PC_fetch= PCF(PC)

mux PCmux(PC_Plus4,PC_TargetE, PCSrcE, PCF);

PC_32bit PCreg(clk,rst,Stall_F, PCF, PC_fetch);

inst_mem InstrMem(PC_fetch, ReadData);


adder_32bit AddFetch(PC_fetch, 32'd4, PC_Plus4);


always@(posedge clk)begin
    
    if(rst || Flush_D)begin
        InstrD    <= 32'b0;
        PCD       <= 32'b0;
        PC_Plus4D <= 32'b0;
    end
    else if(!Stall_D) begin
        InstrD    <= ReadData;
        PCD       <= PC_fetch;
        PC_Plus4D <= PC_Plus4;
    end
//    else begin
//        InstrD <= InstrD ;
//        PCD <= PCD;
//        PC_Plus4D <= PC_Plus4D;
//    end
    
end



endmodule
