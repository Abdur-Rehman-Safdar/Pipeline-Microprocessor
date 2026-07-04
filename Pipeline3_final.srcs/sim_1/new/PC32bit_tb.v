`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 02:22:52 PM
// Design Name: 
// Module Name: PC32bit_tb
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


module PC32bit_tb( );
reg clk,rst;
wire [31:0]count;

PC32bit PC(clk,rst,count);

always #5 clk=~clk;
initial begin
    clk=1'b0;
    rst=1'b1;
    #20;
    rst=1'b0;
    #200;
    $finish;
    end
endmodule
