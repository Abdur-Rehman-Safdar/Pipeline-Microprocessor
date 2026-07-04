`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 08:21:28 PM
// Design Name: 
// Module Name: data_mem
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




module data_mem(input clk,
input mem_write,
input [31:0]address,
input [31:0]write_data,
output [31:0]read_data );


reg[7:0] memory [1023:0];
always@(posedge clk) begin

    //write opertation
    if(mem_write)begin
    memory[address]     <=write_data[7:0];
    memory[address + 1] <=write_data[15:8];
    memory[address + 2] <=write_data[23:16];
    memory[address + 3] <=write_data[31:24];
    
    end
    
 
end
    

    //read operation

 assign  read_data [7:0]    = memory[address];
 assign  read_data [15:8]   = memory[address+1];
 assign  read_data [23:16]  = memory[address+2];
 assign  read_data [31:24]  = memory[address+3];
 
endmodule
