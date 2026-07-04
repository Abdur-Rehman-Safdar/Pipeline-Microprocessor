`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 06:36:50 PM
// Design Name: 
// Module Name: Memory_cycle
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


module Memory_cycle(input clk, rst,
input RegWrite_M, 
input [1:0]ResultSrc_M,
input MemWrite_M,
input [31:0] ALUResult_M,
input [31:0] WriteData_M,
input [4:0] RD_M,
input [31:0] PC_Plus4_M,
output reg RegWrite_W,
output reg [1:0]ResultSrc_W,
output reg [31:0]ALUResult_W,
output reg [31:0]ReadData_W,
output reg [4:0]RD_W,
output reg [31:0] PC_Plus4_W

    );
    
wire [31:0]RD_datamem;

data_mem DataMem(clk, MemWrite_M, ALUResult_M, WriteData_M, RD_datamem);

always @(posedge clk) begin

    if(rst) begin
        RegWrite_W <= 0;
        ResultSrc_W <= 0;
        ALUResult_W <= 0;
        ReadData_W <= 0;
        RD_W <= 0;
        PC_Plus4_W <= 0;

    end
    else begin
        RegWrite_W <= RegWrite_M;
        ResultSrc_W <= ResultSrc_M;
        ALUResult_W <= ALUResult_M ;
        ReadData_W <= RD_datamem ;
        RD_W <=  RD_M;
        PC_Plus4_W <= PC_Plus4_M ;
    end
    
end   
    
     
    
endmodule
