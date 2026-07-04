`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 06:17:23 PM
// Design Name: 
// Module Name: main_decoder
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


module main_decoder(
    input  [31:0]instruction,
    output reg       RegWrite,
    output reg  [1:0]ResultSrc,
    output reg       MemWrite,
    output reg       Jump,
    output reg       Branch,
    output reg [2:0]alu_control,
    output reg       ALUSrc,
    output reg [1:0] ImmSrc
);

    
//reg  RegWrite,MemWrite,Jump,Branch, ALUSrc;
//reg [2:0]alu_control;
//reg [1:0] ImmSrc,ResultSrc;


wire [6:0]Op = instruction[6:0];
reg [1:0]ALUOp;
wire [6:0]func7;
assign func7 = (Op==7'b0110011)?instruction[31:25]:7'b0;
wire [1:0]Opfunc;
assign Opfunc={Op[5], func7[5]} ;
always @(*) begin
    case(Op)

        // lw instruction
        7'b0000011: begin
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00;
            ALUSrc    = 1'b1;
            MemWrite  = 1'b0;
            ResultSrc = 2'b01; // Select Data Memory data
            Branch    = 1'b0;
            Jump      = 1'b0;
            ALUOp     = 2'b00;
        end

        // sw instruction
        7'b0100011: begin
            RegWrite  = 1'b0;
            ImmSrc    = 2'b01;
            ALUSrc    = 1'b1;
            MemWrite  = 1'b1;
            ResultSrc = 2'b00; //for stall
            Branch    = 1'b0;
           Jump      = 1'b0;
            ALUOp     = 2'b00;
        end
        // addi instruction (I-type ALU)
        7'b0010011: begin
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00;
            ALUSrc    = 1'b1;
            MemWrite  = 1'b0;
            ResultSrc = 2'b00; // Select ALU Result
            Branch    = 1'b0;
            Jump      = 1'b0;
            ALUOp     = 2'b00; // ADD operation directly
        end
        // R-type instruction
        7'b0110011: begin
            RegWrite  = 1'b1;
            ImmSrc    = 2'b00;
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 2'b00; // Select ALU Result
            Branch    = 1'b0;
            Jump      = 1'b0;
            ALUOp     = 2'b10;
        end

        // beq instruction
        7'b1100011: begin
            RegWrite  = 1'b0;
            ImmSrc    = 2'b10;
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 2'b00;
            Branch    = 1'b1;
           Jump      = 1'b0;
            ALUOp     = 2'b01;
        end
        // jal instruction 
        7'b1101111: begin
            RegWrite  = 1'b1;
            ImmSrc    = 2'b11;
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 2'b10;   // Route PC+4 back to WriteBack register data!
            Branch    = 1'b0;
            Jump      = 1'b1;    
            ALUOp     = 2'b00;
        end
        // default case
        default: begin
            RegWrite  = 1'b0;
            ImmSrc    = 2'b00;
            ALUSrc    = 1'b0;
            MemWrite  = 1'b0;
            ResultSrc = 2'b00;
            Branch    = 1'b0;
            Jump      = 1'b0;
            ALUOp     = 2'b00;
        end

    endcase
end

always @(*) begin
    case(ALUOp)
        2'b00: alu_control = 3'b000; // lw, sw -> ADD 
        2'b01: alu_control = 3'b001; // beq -> SUB 
        
        2'b10: begin // R-type instructions
            case(instruction[14:12]) 
                3'b000: begin
                    if (Opfunc == 2'b11) 
                        alu_control = 3'b001; // sub 
                    else 
                        alu_control = 3'b000; // add 
                end
                3'b110:  alu_control = 3'b011; // or  
                3'b111:  alu_control = 3'b010; // and 
                default: alu_control = 3'b000; 
            endcase
        end
        default: alu_control = 3'b000; 
    endcase
end

//always@(*) begin
//    RegWriteD = RegWrite; 
//    MemWriteD = MemWrite;
//    JumpD = Jump;
//    BranchD = Branch; 
//    ALUSrcD = ALUSrc;
//    ALUControlD = alu_control;
//    ImmSrcD = ImmSrc;
//    ResultSrcD = ResultSrc;


//end
//assign alu_control = (ALUOp==2'b00) ? 3'b010 : // lw, sw
//         (ALUOp==2'b01) ? 3'b110 : // beq
//         (ALUOp==2'b10 && instruction[14:12]==3'b000 && instruction[31:25]==7'h20) ? 3'b110 : // sub
//         (ALUOp==2'b10 && instruction[14:12]==3'b000) ? 3'b010 : // add
//         (ALUOp==2'b10 && instruction[14:12]==3'b110) ? 3'b001 : // or
//         (ALUOp==2'b10 && instruction[14:12]==3'b111) ? 3'b000 : 3'b010;

endmodule
