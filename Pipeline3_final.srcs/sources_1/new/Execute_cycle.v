`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 05:30:15 PM
// Design Name: 
// Module Name: Execute_cycle
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


module Execute_cycle(input clk,rst,
input [31:0]ReadData1_E, ReadData2_E,PC_E,  Imm_ext_E,PC_Plus4_E,
input [4:0]RD_E,
input      RegWrite_E,
input [1:0]ResultSrc_E,
input      MemWrite_E,
input      Jump_E,
input      Branch_E,
input [2:0]ALUControl_E,
input      ALUSrc_E,
input [4:0] Rs1_E,Rs2_E,  //hazard
input [31:0] ALUResult_EM, //forwarded from Memory stage output
input [31:0] Result_E,     // forwarded from Writeback
input [1:0]Forward_AE, Forward_BE,
output PCSrc_E, 
output reg RegWrite_M, 
output reg[1:0]ResultSrc_M,
output reg MemWrite_M,
output reg[31:0] ALUResult_M,
output reg[31:0] WriteData_M,
output reg[4:0] RD_M,
output reg[31:0] PC_Plus4_M,
output [31:0] PC_Target_E
//

);

wire zero_flag;
wire [31:0]SrcA_E;
wire [31:0]SrcB_E;
wire [31:0]ALUResult_E;
wire [31:0] WriteData_E;



//Hazard Mux 1
mux3_1 RD1Mux(ReadData1_E, Result_E, ALUResult_EM, Forward_AE, SrcA_E);

//Hazard Mux2

mux3_1 RD2Mux(ReadData2_E, Result_E, ALUResult_EM, Forward_BE, WriteData_E);



//ALu mux
mux ALUmux(WriteData_E, Imm_ext_E, ALUSrc_E, SrcB_E);

//ALU
alu_logic ALUunit(SrcA_E, SrcB_E, ALUControl_E, ALUResult_E, zero_flag);

//Adder
adder_32bit ImmAdder(PC_E, Imm_ext_E, PC_Target_E);

//PCSrc_E for PC counter
assign PCSrc_E = ((zero_flag && Branch_E) || Jump_E); 

always @(posedge clk) begin
    if(rst) begin
        RegWrite_M  <= 1'b0; 
        ResultSrc_M <= 2'b0;
        MemWrite_M  <= 1'b0;
        ALUResult_M <= 32'b0;
        WriteData_M <= 32'b0;
        PC_Plus4_M  <= 32'b0; 
        RD_M <= 5'b0;
           
    
    end
    else begin
        RegWrite_M  <= RegWrite_E ; 
        ResultSrc_M <= ResultSrc_E ;
        MemWrite_M  <= MemWrite_E;
        ALUResult_M <= ALUResult_E ;
        WriteData_M <= WriteData_E;
        PC_Plus4_M  <= PC_Plus4_E; 
        RD_M        <= RD_E ;
    end

end

//assign Rs1_Eout = Rs1_E;
//assign Rs2_Eout = Rs2_E;

endmodule
