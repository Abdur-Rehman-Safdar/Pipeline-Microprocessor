`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/18/2026 02:28:58 PM
// Design Name: 
// Module Name: inst_mem
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


module inst_mem(input [31:0]PC, output [31:0]inst_code);


reg [7:0] Memory [63:0]; 
integer i;
initial begin

//======================Hazards ======================
    for (i = 0; i < 64; i = i + 4) begin
        Memory[i]     = 8'h13;
        Memory[i + 1] = 8'h00;
        Memory[i + 2] = 8'h00;
        Memory[i + 3] = 8'h00;
    end
       //--------------------------------------------------------------
        // 0x00: addi x4, x0, 10          Hex: 0x00A00213
        // I-type | imm=10 | rs1=x0 | funct3=000 | rd=x4 | op=0010011
        //--------------------------------------------------------------
        Memory[0]  = 8'h13;
        Memory[1]  = 8'h02;
        Memory[2]  = 8'hA0;
        Memory[3]  = 8'h00;
 
        //--------------------------------------------------------------
        // 0x04: sw x4, 4(x11)            Hex: 0x0045A223
        // S-type | imm=4 | rs2=x4 | rs1=x11 | funct3=010 | op=0100011
        // *** DATA HAZARD: x4 written by addi above ? FORWARDING (EX?EX) ***
        //--------------------------------------------------------------
        Memory[4]  = 8'h23;
        Memory[5]  = 8'hA2;
        Memory[6]  = 8'h45;
        Memory[7]  = 8'h00;
 
        //--------------------------------------------------------------
        // 0x08: lw x5, 4(x11)            Hex: 0x0045A283
        // I-type | imm=4 | rs1=x11 | funct3=010 | rd=x5 | op=0000011
        // *** LOAD-USE STALL: next instruction (sub) needs x5 ? 1 stall cycle ***
        //--------------------------------------------------------------
        Memory[8]  = 8'h83;
        Memory[9]  = 8'hA2;
        Memory[10] = 8'h45;
        Memory[11] = 8'h00;
 
        //--------------------------------------------------------------
        // 0x0C: jal x8, +8               Hex: 0x0080046F
        // J-type | offset=+8 | rd=x8 | op=1101111
        // Target = 0x0C + 8 = 0x14   |   x8 = 0x0C + 4 = 0x10
        // *** CONTROL HAZARD: instruction at 0x10 is FLUSHED (wrong path) ***
        //--------------------------------------------------------------
        Memory[12] = 8'h6F;
        Memory[13] = 8'h04;
        Memory[14] = 8'h80;
        Memory[15] = 8'h00;
 
        //--------------------------------------------------------------
        // 0x10: jal x12, +12             Hex: 0x00C0066F
        // J-type | offset=+12 | rd=x12 | op=1101111
        // *** THIS INSTRUCTION IS FLUSHED - never executes ***
        // *** x12 retains its original value (0 after reset) ***
        //--------------------------------------------------------------
        Memory[16] = 8'h6F;
        Memory[17] = 8'h06;
        Memory[18] = 8'hC0;
        Memory[19] = 8'h00;
 
        //--------------------------------------------------------------
        // 0x14: sub x6, x6, x5           Hex: 0x40530333
        // R-type | funct7=0100000 | rs2=x5 | rs1=x6 | funct3=000 | rd=x6 | op=0110011
        // x5 was loaded by lw (stall ensures correct value via forwarding)
        // *** DATA HAZARD: x5 from lw ? FORWARDING after stall ***
        //--------------------------------------------------------------
        Memory[20] = 8'h33;
        Memory[21] = 8'h03;
        Memory[22] = 8'h53;
        Memory[23] = 8'h40;
 
        //--------------------------------------------------------------
        // 0x18: beq x0, x0, -8           Hex: 0xFE000CE3
        // B-type | offset=-8 | rs1=x0 | rs2=x0 | funct3=000 | op=1100011
        // Target = 0x18 + (-8) = 0x10
        // x0==x0 always ? branch ALWAYS TAKEN
        // *** CONTROL HAZARD: flushes instruction(s) fetched after beq ***
        //--------------------------------------------------------------
        Memory[24] = 8'hE3;
        Memory[25] = 8'h0C;
        Memory[26] = 8'h00;
        Memory[27] = 8'hFE;
 
        //--------------------------------------------------------------
        // 0x1C: add x10, x9, x5          Hex: 0x00548533
        // R-type | funct7=0000000 | rs2=x5 | rs1=x9 | funct3=000 | rd=x10 | op=0110011
        // (Reachable only if branch not taken - here it will be FLUSHED on first pass)
        //--------------------------------------------------------------
        Memory[28] = 8'h33;
        Memory[29] = 8'h85;
        Memory[30] = 8'h54;
        Memory[31] = 8'h00;
 
        //--------------------------------------------------------------
        // 0x20+: NOPs to drain the pipeline (addi x0, x0, 0 = 0x00000013)
        //--------------------------------------------------------------
        Memory[32] = 8'h13; Memory[33] = 8'h00; Memory[34] = 8'h00; Memory[35] = 8'h00;
        Memory[36] = 8'h13; Memory[37] = 8'h00; Memory[38] = 8'h00; Memory[39] = 8'h00;
        Memory[40] = 8'h13; Memory[41] = 8'h00; Memory[42] = 8'h00; Memory[43] = 8'h00;
        Memory[44] = 8'h13; Memory[45] = 8'h00; Memory[46] = 8'h00; Memory[47] = 8'h00;
 
    end

// --- Instruction 0 (Address 0 to 3): addi x5, x0, 10 ---
         // 0x00: addi x5, x0, 10      -> 0x00A00293
//       Memory[0]  = 8'h93;
//       Memory[1]  = 8'h02;
//       Memory[2]  = 8'hA0;
//       Memory[3]  = 8'h00;

//       // 0x04: addi x6, x5, -5     -> 0xFFB28313
//       Memory[4]  = 8'h13;
//       Memory[5]  = 8'h83;
//       Memory[6]  = 8'hB2;
//       Memory[7]  = 8'hFF;

//       // 0x08: sw x6, 4(x11)       -> 0x0065A223
//       Memory[8]  = 8'h23;
//       Memory[9]  = 8'hA2;
//       Memory[10] = 8'h65;
//       Memory[11] = 8'h00;

//       // 0x0C: lw x7, 4(x11)       -> 0x0045A383
//       Memory[12] = 8'h83;
//       Memory[13] = 8'hA3;
//       Memory[14] = 8'h45;
//       Memory[15] = 8'h00;

//    Memory[16] = 8'h13; Memory[17] = 8'h00; Memory[18] = 8'h00; Memory[19] = 8'h00;
//    Memory[20] = 8'h13; Memory[21] = 8'h00; Memory[22] = 8'h00; Memory[23] = 8'h00;
//    Memory[24] = 8'h13; Memory[25] = 8'h00; Memory[26] = 8'h00; Memory[27] = 8'h00;




//// --- Instruction 0 (Address 0 to 3): addi x5, x0, 10 ---
//        // Hex: 0x00A00293
//        Memory[0] = 8'h93; // LSB
//        Memory[1] = 8'h02;
//        Memory[2] = 8'ha0;
//        Memory[3] = 8'h00; // MSB 

//        // --- Instruction 1 (Address 4 to 7): addi x6, x5, -5 ---
//        // Hex: 0xFFB28313
//        Memory[4] = 8'h13; // LSB
//        Memory[5] = 8'h83;
//        Memory[6] = 8'hb2;
//        Memory[7] = 8'hff; // MSB

//        // --- Instruction 2 (Address 8 to 11): add x7, x5, x6 ---
//        // Hex: 0x006283B3
//        Memory[8]  = 8'hB3; // LSB
//        Memory[9]  = 8'h83;
//        Memory[10] = 8'h62;
//        Memory[11] = 8'h00; // MSB       

//        // --- Instruction 3 (Address 12 to 15): NOP ---
//        Memory[12] = 8'h13; 
//        Memory[13] = 8'h00;
//        Memory[14] = 8'h00;
//        Memory[15] = 8'h00;





//=========================================
//         //   0x00A00293	addi x5 x0 10
//        Memory[0] = 8'h93; // LSB
//        Memory[1] = 8'h02;
//        Memory[2] = 8'ha0;
//        Memory[3] = 8'h00; // MSB 

//        // 0xFFB00313	addi x6 x0 -5
        
//        Memory[4] = 8'h13;
//        Memory[5] = 8'h03;
//        Memory[6] = 8'hb0;
//        Memory[7] = 8'hff;

//        // 0x00828393	addi x7 x0 8
//        Memory[8]  = 8'h93;
//        Memory[9]  = 8'h03;
//        Memory[10] = 8'h80;
//        Memory[11] = 8'h00;       

//        // NOP instr
        
//        Memory[12]= 8'h13; 
//        Memory[13]= 8'h00;
//        Memory[14]= 8'h00;
//        Memory[15]= 8'h00;
//============================================================
        // --- Instruction 0 (Address 0 to 3): add x4, x0, x5 ---
        // Hex: 0x00500233
//         Memory[0] = 8'h33; // LSB
//        Memory[1] = 8'h02;
//        Memory[2] = 8'h50;
//        Memory[3] = 8'h00; // MSB      

//   

//        // --- Instruction 1 (Address 4 to 7): L7: lw x5, 0(x4) ---
//        // Hex: 0x00020283
//        Memory[4] = 8'h83;
//        Memory[5] = 8'h02;
//        Memory[6] = 8'h02;
//        Memory[7] = 8'h00;

//        // --- Instruction 2 (Address 8 to 11): sw x5, 0(x5) ---
//        // Hex: 0x0052a023
//        Memory[8] = 8'h23;
//        Memory[9] = 8'ha0;
//        Memory[10] = 8'h52;
//        Memory[11] = 8'h00;

//        // --- Instruction 3 (Address 12 to 15): jal x6, 8 (Target PC = 12 + 8 = 20) ---
//        // Hex: 0x0080036f
//        Memory[12] = 8'h6f;
//        Memory[13] = 8'h03;
//        Memory[14] = 8'h80;
//        Memory[15] = 8'h00;

//        // --- Instruction 4 (Address 16 to 19): add x7, x4, x0 ---
//        // Hex: 0x000203b3
//        Memory[16] = 8'hb3;
//        Memory[17] = 8'h03;
//        Memory[18] = 8'h02;
//        Memory[19] = 8'h00;

//        // --- Instruction 5 (Address 20 to 23): sub x8, x7, x4 ---
//        // Hex: 0x40438433
//        Memory[20] = 8'h33;
//        Memory[21] = 8'h84;
//        Memory[22] = 8'h33;
//        Memory[23] = 8'h40;

//        // --- Instruction 6 (Address 24 to 27): beq x4, x4, L7 (Target PC = 24 - 20 = 4) ---
//        // Hex: 0xfe4206e3
//        Memory[24] = 8'he3;
//        Memory[25] = 8'h06;
//        Memory[26] = 8'h42;
//        Memory[27] = 8'hfe;
 

    // Continuous data read using Little-Endian mapping
    assign inst_code = {Memory[PC + 3], Memory[PC + 2], Memory[PC + 1], Memory[PC]};

endmodule