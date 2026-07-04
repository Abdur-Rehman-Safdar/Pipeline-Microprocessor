`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 08:23:29 PM
// Design Name: 
// Module Name: data_mem_tb
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




module data_mem_tb( );
reg clk;
reg mem_write;
reg [31:0]address;
reg [31:0]data_in;
wire[31:0]data_out ;

data_mem dataMem(clk,mem_write,address,data_in,data_out );

always #5 clk = ~clk;
   
    initial begin
        // Initialize Inputs
        clk = 0;
       
        mem_write = 0;
        address = 0;
        data_in = 0;

    
        #20;
        
        address = 32'd4;
        data_in = 32'haabbccdd;
        mem_write = 1;
     
        #10; 
  
        mem_write = 0;
        #10;

 
        address = 32'd4;
       
        #10; 
       
     
        address = 32'd8;
        data_in = 32'h12345678;
        mem_write = 1;
        
        #10;
        mem_write = 0;
      
        
        #20;
        $finish;
    end


endmodule
