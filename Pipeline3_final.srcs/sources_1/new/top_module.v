`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2026 02:52:41 PM
// Design Name: 
// Module Name: inst_mem
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


module top_module(
    input clk, rst,
    output reg [31:0] pc,
    output reg [31:0] instruction,
    output reg [4:0]  rs1, rs2, rd
);

// Fetch Cycle
wire PCSrc_E;
wire [31:0] PC_Target_E;
wire [31:0]Instr_D, PC_D, PC_Plus4_D;

//Decode Cycle

wire RegWrite_W;
wire [4:0]RD_W_out;
wire [31:0]Result_W;
wire [31:0]ReadData1_E, ReadData2_E,PC_E, Imm_ext_E, PC_Plus4_E;
wire [4:0]RD_E;

wire       RegWrite_E;
wire  [1:0]ResultSrc_E;
wire       MemWrite_E;
wire        Jump_E;
wire        Branch_E;
wire [2:0]ALUControl_E;
wire        ALUSrc_E;
wire  [1:0] ImmSrc_E;

wire [4:0] Rs1_D, Rs2_D,Rs1_E,Rs2_E; //hazards


//Execute Cycle
wire RegWrite_M; 
wire [1:0]ResultSrc_M;
wire MemWrite_M;
wire [31:0] ALUResult_M;
wire [31:0] WriteData_M;
wire [4:0] RD_M;
wire [31:0] PC_Plus4_M;

wire [31:0] ALUResult_EM,Result_E; //hazards
wire [1:0]Forward_AE, Forward_BE;  //hazards


//Memory Cycle
//wire RegWrite_W; 
wire [1:0]ResultSrc_W;
wire [31:0]ReadData_W;
wire [31:0] ALUResult_W;
wire [4:0] RD_W;
wire [31:0] PC_Plus4_W;

// WriteBack cycle
wire RegWrite_W_out;


//Hazard

wire Stall_D,Stall_F;
wire Flush_D,Flush_E;




// =================================================================
// Module Instantiations
// =================================================================

Fetch_cycle FetchCycle(clk, rst,Flush_D,Stall_F,Stall_D,PC_Target_E, PCSrc_E, Instr_D, PC_D, PC_Plus4_D); //stall 1


Decode_cycle DecodeCycle(clk,rst, Flush_E, Instr_D, PC_D, PC_Plus4_D, RegWrite_W_out,RD_W_out, Result_W,
ReadData1_E, ReadData2_E,PC_E, Imm_ext_E, PC_Plus4_E, RD_E, RegWrite_E, ResultSrc_E,
MemWrite_E, Jump_E, Branch_E, ALUControl_E, ALUSrc_E, ImmSrc_E ,Rs1_D, Rs2_D, Rs1_E,Rs2_E); //hazards




Execute_cycle ExecuteCycle(clk,rst,ReadData1_E, ReadData2_E,PC_E,  Imm_ext_E,PC_Plus4_E,
RD_E, RegWrite_E,ResultSrc_E, MemWrite_E,Jump_E,  Branch_E,ALUControl_E, ALUSrc_E, 
Rs1_E, Rs2_E, ALUResult_M, Result_W, Forward_AE, Forward_BE,  //hazards
PCSrc_E, RegWrite_M, ResultSrc_M, MemWrite_M, ALUResult_M, WriteData_M, RD_M,
PC_Plus4_M, PC_Target_E );




Memory_cycle MemCycle(clk, rst, RegWrite_M, ResultSrc_M, MemWrite_M, ALUResult_M,
WriteData_M,  RD_M, PC_Plus4_M,
RegWrite_W, ResultSrc_W, ALUResult_W, ReadData_W, RD_W, PC_Plus4_W );

WriteBack_cycle WriteBackCycle(clk,rst, RegWrite_W, ResultSrc_W, ALUResult_W,
ReadData_W, RD_W, PC_Plus4_W, Result_W, RegWrite_W_out,RD_W_out

);

// Hazard Unit

//hazard_handling HazardHandling(Rs1_Eout, Rs2_Eout,RD_M,RD_W_out, RegWrite_M, RegWrite_W_out, Forward_AE, Forward_BE   );


hazard_handling HazardHandling( Rs1_D, Rs2_D, Rs1_E, Rs2_E, RD_E, RD_M,RD_W,
RegWrite_M, RegWrite_W,  PCSrc_E, ResultSrc_E,
Forward_AE, Forward_BE,
Stall_F, Stall_D, Flush_D, Flush_E  );




always @(*) begin
    pc          = PC_D;
    instruction = Instr_D;
    rs1         = Instr_D[19:15];
    rs2         = Instr_D[24:20];
    rd          = Instr_D[11:7];
end

endmodule
