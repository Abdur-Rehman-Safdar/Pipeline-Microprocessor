`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/23/2026 03:31:59 PM
// Design Name: 
// Module Name: Decode_cycle
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


module Decode_cycle(input clk, rst,Flush_E,
input[31:0]Instruction,PC_D,PC_Plus4D, 
input RegWrite_W,
input [4:0]RD_W, 
input [31:0]Result_W,
output reg [31:0]ReadData1_E, ReadData2_E,PC_E, Imm_ext_E, PC_Plus4_E,
output reg [4:0]RD_E,
output reg       RegWrite_E,
output reg  [1:0]ResultSrc_E,
output reg       MemWrite_E,
output reg       Jump_E,
output reg       Branch_E,
output reg [2:0]ALUControl_E,
output reg       ALUSrc_E,
output reg [1:0] ImmSrc_E,
output reg [4:0] Rs1_D, Rs2_D, Rs1_E,Rs2_E
);

wire       RegWrite_D;
wire  [1:0]ResultSrc_D;
wire       MemWrite_D;
wire       Jump_D;
wire       Branch_D;
wire  [2:0]ALUControl_D;
wire       ALUSrc_D;
wire  [1:0]ImmSrc_D;
 
//reg [4:0]RD_D;
wire [4:0]RD_D = Instruction[11:7];


wire [4:0]Read_A1 = Instruction[19:15];
wire [4:0]Read_A2 = Instruction[24:20];

wire [31:0]ReadData1_D, ReadData2_D;

wire [31:0]imm_ext_D; 



// hazards
//wire [4:0] Rs1_D,Rs2_D;                     // control hazards
always@(*)begin
    Rs1_D = Instruction[19:15];
    Rs2_D = Instruction[24:20];
end

// main decoder and COntrol Unit
main_decoder ControlUnit(Instruction, RegWrite_D,ResultSrc_D,
MemWrite_D, Jump_D, Branch_D,ALUControl_D,ALUSrc_D,ImmSrc_D
);


//Reg file
reg_file FileReg(Read_A1,Read_A2,RD_W, Result_W,RegWrite_W,clk,rst,ReadData1_D,ReadData2_D);

//Immidiate extender
imm_ext ImmExt(ImmSrc_D,Instruction,imm_ext_D );

always @(posedge clk)begin
    if(rst || Flush_E) begin
    
        //Control pins
        RegWrite_E   <= 1'b0;
        ResultSrc_E  <= 2'b0;
        MemWrite_E   <= 1'b0;
        Jump_E       <= 1'b0;
        Branch_E     <= 1'b0;
        ALUControl_E <= 3'b0;
        ALUSrc_E     <= 1'b0;
        ImmSrc_E     <= 2'b0;
        
        //Forward data
        ReadData1_E <= 32'b0;
        ReadData2_E <= 32'b0;
        PC_E        <= 32'b0;
        RD_E        <= 5'b0;
        Imm_ext_E   <= 32'b0;
        PC_Plus4_E  <= 32'b0;
        
        //control hazards
        Rs1_E <= 5'b0;
        Rs2_E <= 5'b0; 
        
        end
    else  begin
        RegWrite_E   <= RegWrite_D;
        ResultSrc_E  <= ResultSrc_D;
        MemWrite_E   <= MemWrite_D;
        Jump_E       <= Jump_D;
        Branch_E     <= Branch_D;
        ALUControl_E <= ALUControl_D;
        ALUSrc_E     <= ALUSrc_D;
        ImmSrc_E     <= ImmSrc_D;
        
        //Forward data
        ReadData1_E <= ReadData1_D;
        ReadData2_E <= ReadData2_D;
        PC_E        <= PC_D ;
        RD_E        <= RD_D;
        Imm_ext_E   <=  imm_ext_D;
        PC_Plus4_E  <= PC_Plus4D; 
        
        //Control hazards
        Rs1_E <= Rs1_D;
        Rs2_E <= Rs2_D;   

    end    
//    else begin
//      //  RD_D <= RDd;
        
//        //Control pins
//        RegWrite_E   <= RegWrite_E;
//        ResultSrc_E  <= ResultSrc_E;
//        MemWrite_E   <= MemWrite_E;
//        Jump_E       <= Jump_E;
//        Branch_E     <= Branch_E;
//        ALUControl_E <= ALUControl_E;
//        ALUSrc_E     <= ALUSrc_E;
//        ImmSrc_E     <= ImmSrc_E;
        
//        //Forward data
//        ReadData1_E <= ReadData1_E;
//        ReadData2_E <= ReadData2_E;
//        PC_E        <= PC_E ;
//        RD_E        <= RD_E;
//        Imm_ext_E   <=  Imm_ext_E;
//        PC_Plus4_E  <= PC_Plus4_E; 
        
//        //Control hazards
//        Rs1_E <= Rs1_E;
//        Rs2_E <= Rs2_E;   

//    end
        
end



endmodule
