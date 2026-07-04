`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 03:17:30 PM
// Design Name: 
// Module Name: mux
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


module mux3_1(input [31:0]a,b,c, input[1:0] s, output reg[31:0]y);

always@(*) begin

    case(s)
    2'b00: y=a;  
    2'b01: y=b;  
    2'b10: y=c;
    default: y=a;   
    endcase

end


endmodule
