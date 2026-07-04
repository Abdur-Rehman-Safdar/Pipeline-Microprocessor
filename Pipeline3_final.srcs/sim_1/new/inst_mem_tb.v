`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 02:55:30 PM
// Design Name: 
// Module Name: inst_mem_tb
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


module inst_mem_tb();
reg [31:0]PC;
wire [31:0]inst_code;

inst_mem instrMem(PC,inst_code);
initial begin
    PC=32'd0;#10;
    PC=32'd4;#10;
    PC=32'd8;#10;
    PC=32'd12;#10;
    PC=32'd16;#10;
    $finish;
end

endmodule
