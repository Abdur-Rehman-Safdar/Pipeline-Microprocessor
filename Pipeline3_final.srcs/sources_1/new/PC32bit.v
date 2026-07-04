`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 02:20:38 PM
// Design Name: 
// Module Name: PC32bit
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


module PC_32bit(
    input clk,
    input rst, Stall_F,
    input [31:0] pc_next,  
    output reg [31:0] pc_out // Current PC address
);

    always @(posedge clk) begin
        if (rst) begin
            pc_out <= 32'b0;    // Reset par PC 0 se start hoga
        end
        else if(!Stall_F)begin
            pc_out <= pc_next;  // Har clock cycle par naya address load hoga
        end
        else begin
            pc_out <= pc_out;  // Har clock cycle par naya address load hoga
        end
    end

endmodule

