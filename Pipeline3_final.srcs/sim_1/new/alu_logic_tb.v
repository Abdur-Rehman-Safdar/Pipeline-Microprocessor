`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 08:13:54 PM
// Design Name: 
// Module Name: alu_logic_tb
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

module alu_logic_tb( );

reg [31:0]in1,in2;
reg [2:0]alu_control;
wire [31:0] result;
wire zer0_flag;

alu_logic ALU(in1,in2,alu_control, result,zer0_flag);

initial begin
    in1=0;
    in2=0;
    alu_control=0;
    
    //ADD
    #10;
    in1=32'hF0F0F0F0;
    in2=32'h0F0F0F0F;
    alu_control=3'b000;
    
    //SUB
    #10;
    in1=32'hF0F0F0F0;
    in2=32'h0F0F0F0F;
    alu_control=3'b001;
    #10;
    
    //AND
    in1=20;
    in2=15;
    alu_control=3'b010;
    #10;
    
    //OR
    in1=20;
    in2=15;
    alu_control=3'b011;
    #10;
    
    //BEQ Equal
    in1=100;
    in2=100;
    alu_control=3'b001;
    #10;
    
    //BEQ Not equal
    in1=100;
    in2=50;
    alu_control=3'b001;
    #10;
    $finish;
    end




endmodule