`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 03:01:59 PM
// Design Name: 
// Module Name: reg_file
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


module reg_file(
input [4:0]Read_A1,Read_A2,Write_A3, // rs reg & rd addressess
input [31:0]WD3,
input RegWrite,clk,rst,
output [31:0]RD1,RD2 );

reg [31:0]reg_memory [31:0];

integer i;
always@(posedge clk) begin
    if(rst) begin
        for(i=0;i<32;i=i+1) begin
        reg_memory[i]<=0;  // 
        end
        
     end
     else if(RegWrite && (Write_A3!=0))begin
        reg_memory[Write_A3]<=WD3;
     end
    end        
    
    // continuous read
//assign RD1=reg_memory[Read_A1];
//assign RD2=reg_memory[Read_A2];

wire bypass_a1 = RegWrite && (Write_A3 != 5'd0) && (Write_A3 == Read_A1);
wire bypass_a2 = RegWrite && (Write_A3 != 5'd0) && (Write_A3 == Read_A2);

// Continuous read with same-cycle writeback bypass.
assign RD1 = (Read_A1 == 5'd0) ? 32'b0 : (bypass_a1 ? WD3 : reg_memory[Read_A1]);
assign RD2 = (Read_A2 == 5'd0) ? 32'b0 : (bypass_a2 ? WD3 : reg_memory[Read_A2]);
endmodule
