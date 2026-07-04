`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 03:13:52 PM
// Design Name: 
// Module Name: reg_file_tb
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


module reg_file_tb();
reg [4:0]A1,A2,A3;
reg [31:0]WD3;
reg RegWrite,clk,rst;
wire [31:0]RD1,RD2;


reg_file RegFile(A1,A2,A3,WD3, RegWrite,clk,rst,RD1,RD2 );
always #5 clk=~clk;
// initial begin
//    $monitor("time=%0t | reset=%b | regwrite=%b | write_reg = %0d | write_data = %0d |read_reg_num1=%0d | read_reg_num2 = %0d | read_data1=%d | read_data2=%d",
//    $time,rst,RegWrite,A3,WD3 ,A1,A2,RD1,RD2);
// end
initial
    begin
    
        clk = 1'b0;
        rst = 1'b1;
        A1 = 5'd0;
        A2 = 5'd0;
        A3 = 5'd0;
        WD3 = 32'd0;
        RegWrite = 1'b0;
       
        #10;
        rst=1'b0;
        A1=5'd5;  // read register x5
        
        #10; 
        A2=5'd10;  // read register x10
        
        #10;
        RegWrite = 1'b1;
        A3 = 5'd5;
        WD3 = 32'd10; // write data=10 at x5
        
        #10;
        A1=5'd5;  // read x5=10
        
        #10;
        RegWrite = 1'b1;
        A3 = 5'd10;
        WD3 = 32'd25; // write data=25 at x10
        
        #10; 
        A2=5'd10;  //read x10
        
        
        
        
        
        #10;
        $finish;
        
        
        
    end

endmodule
