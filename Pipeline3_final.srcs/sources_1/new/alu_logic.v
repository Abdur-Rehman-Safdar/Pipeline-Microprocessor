`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 07:50:24 PM
// Design Name: 
// Module Name: alu_logic
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


module alu_logic(input [31:0]in1,in2,
input [2:0]alu_control,
output reg[31:0] result,
output reg zero_flag);

always @(*) begin
    result = 32'b0;
    case(alu_control)
        3'b000: result = in1 + in2;                         // ADD
        3'b001: result = in1 - in2;                         // SUB
        3'b010: result = in1 & in2;                         // AND
        3'b011: result = in1 | in2;                         // OR

        default: result = 32'b0;
    endcase
    
    //BEW Zero_flag
    zero_flag = (result == 32'b0) ? 1'b1 : 1'b0; 
end
        
    

endmodule