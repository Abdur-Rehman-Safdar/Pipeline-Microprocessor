`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2026 03:52:34 PM
// Design Name: 
// Module Name: hazard_handling
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


module hazard_handling(
input [4:0]Rs1_D, Rs2_D, Rs1_E, Rs2_E, RD_E, RD_M,RD_W,
input RegWrite_M, RegWrite_W,  PCSrc_E,
input [1:0]ResultSrc_E,
output reg [1:0] Forward_AE, Forward_BE,
output Stall_F, Stall_D, Flush_D, Flush_E  );

wire lwStall;

//Forward to solve data hazards when possible
always@(*) begin
Forward_AE = 2'b00;
if ((Rs1_E == RD_M) && RegWrite_M && (Rs1_E != 5'd0))  // Forward from Memory stage
    Forward_AE = 2'b10;
else if ((Rs1_E == RD_W) && RegWrite_W && (Rs1_E != 5'd0)) // Forward from Writeback stage
    Forward_AE = 2'b01;
else 
    Forward_AE = 2'b00;

end

always@(*) begin
Forward_BE = 2'b00;
if ((Rs2_E == RD_M) && RegWrite_M && (Rs2_E != 5'd0))  // Forward from Memory stage
    Forward_BE = 2'b10;
else if ((Rs2_E == RD_W) && RegWrite_W && (Rs2_E != 5'd0)) // Forward from Writeback stage
    Forward_BE = 2'b01;
else 
    Forward_BE = 2'b00;

end

//Stall when a load hazard occurs
assign lwStall = (ResultSrc_E[0] & ((Rs1_D == RD_E) | (Rs2_D == RD_E)));
assign Stall_F = lwStall;
assign Stall_D = lwStall;

//Flush when a branch is taken or a load introduces a bubble:
//assign Flush_D = PCSrc_E & ~lwStall;
assign Flush_D = PCSrc_E ;
assign Flush_E = (lwStall | PCSrc_E);


endmodule
