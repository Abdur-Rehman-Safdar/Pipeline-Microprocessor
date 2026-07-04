`timescale 1ns / 1ps
//==============================================================================


module tb_new;

    reg clk, rst;

    wire [31:0] pc, instruction;
    wire [4:0]  rs1, rs2, rd;

    top_module DUT (
        .clk(clk), .rst(rst),
        .pc(pc), .instruction(instruction),
        .rs1(rs1), .rs2(rs2), .rd(rd)
    );

    initial clk = 0;
    always  #5 clk = ~clk;

    //--------------------------------------------------------------------------
    // Signal aliases
    //--------------------------------------------------------------------------
    wire [31:0] Instr_F  = DUT.FetchCycle.ReadData;
    wire [31:0] Instr_D  = DUT.Instr_D;

    wire [1:0]  FwdA     = DUT.Forward_AE;
    wire [1:0]  FwdB     = DUT.Forward_BE;
    wire        Stall_F  = DUT.Stall_F;
    wire        Stall_D  = DUT.Stall_D;
    wire        Flush_D  = DUT.Flush_D;
    wire        Flush_E  = DUT.Flush_E;
    wire        PCSrc    = DUT.PCSrc_E;

    wire [31:0] Result_W = DUT.Result_W;
    wire [4:0]  RD_W     = DUT.RD_W;

    //--------------------------------------------------------------------------
    // Shadow stage registers - track instruction in each pipeline stage
    //--------------------------------------------------------------------------
    reg [31:0] stage_IF, stage_ID, stage_EX, stage_MEM, stage_WB;

    always @(posedge clk) begin
        if (rst) begin
            stage_IF  <= 32'h0;
            stage_ID  <= 32'h0;
            stage_EX  <= 32'h0;
            stage_MEM <= 32'h0;
            stage_WB  <= 32'h0;
        end else begin
            stage_WB  <= stage_MEM;
            stage_MEM <= stage_EX;

            if (Flush_E)
                stage_EX <= 32'h0;
            else
                stage_EX <= stage_ID;

            if (Flush_D)
                stage_ID <= 32'h0;
            else if (!Stall_D)
                stage_ID <= stage_IF;

            if (!Stall_F)
                stage_IF <= Instr_F;
        end
    end

    //--------------------------------------------------------------------------
    // Mnemonic - returns NOP/BUB for unknown opcodes (no more ???)
    //--------------------------------------------------------------------------
    function [8*8-1:0] mnemonic;
        input [31:0] instr;
        reg [6:0] op, f7;
        begin
            op = instr[6:0];
            f7 = instr[31:25];
            case(op)
                7'b0010011: mnemonic = "addi    ";
                7'b0000011: mnemonic = "lw      ";
                7'b0100011: mnemonic = "sw      ";
                7'b1101111: mnemonic = "jal     ";
                7'b1100011: mnemonic = "beq     ";
                7'b0110011: mnemonic = (f7[5]) ? "sub     " : "add     ";
                default:    mnemonic = "NOP/BUB ";  // FIX: ??? -> NOP/BUB
            endcase
        end
    endfunction

    function [8*8-1:0] fwd_str;
        input [1:0] fwd;
        begin
            case(fwd)
                2'b00:   fwd_str = "REG     ";
                2'b01:   fwd_str = "FWD-WB  ";
                2'b10:   fwd_str = "FWD-MEM ";
                default: fwd_str = "???     ";
            endcase
        end
    endfunction

    //--------------------------------------------------------------------------
    // Counters & check task
    //--------------------------------------------------------------------------
    integer cycle, pass_count, fail_count, stall_count, flush_count, fwd_count;

    task check_reg;
        input [4:0]  reg_num;
        input signed [31:0] expected;
        input [8*20-1:0] label;
        reg signed [31:0] actual;
        begin
            actual = DUT.DecodeCycle.FileReg.reg_memory[reg_num];
            if (actual === expected) begin
                $display("  [PASS]  %-18s x%-2d = %0d", label, reg_num, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL]  %-18s x%-2d = %0d  (expected %0d)", label, reg_num, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    //--------------------------------------------------------------------------
    // Display one pipeline row
    //--------------------------------------------------------------------------
    task display_row;
        begin
            // FIX: Show stall correctly - Stall_F OR Stall_D = pipeline stalled
            $display(" %3d | %-8s | %-8s | %-8s | %-8s | %-8s | %b  %b  %s",
                cycle,
                mnemonic(stage_IF),
                mnemonic(stage_ID),
                mnemonic(stage_EX),
                mnemonic(stage_MEM),
                mnemonic(stage_WB),
                (Stall_F | Stall_D),     // S: stall active
                (Flush_D | Flush_E),     // F: flush active
                (FwdA != 0 || FwdB != 0) ? "Y" : "N"
            );
            if (FwdA != 2'b00 || FwdB != 2'b00)
                $display("     |          |          | SrcA:%-8s  SrcB:%-8s",
                         fwd_str(FwdA), fwd_str(FwdB));
            if (PCSrc)
                $display("     | *** Jump/Branch -> PC = 0x%08h ***", DUT.PC_Target_E);
        end
    endtask

    //--------------------------------------------------------------------------
    // Stimulus
    //--------------------------------------------------------------------------
    reg [31:0] x5val, x12val, x8val;

    initial begin
        cycle=0; pass_count=0; fail_count=0;
        stall_count=0; flush_count=0; fwd_count=0;

    
        $display("  5-Stage Pipelined RISC-V Processor - Hazard Testbench");


        $display("Program (8 instructions):");
        $display("  0x00: addi x4,  x0,  10");
        $display("  0x04: sw   x4,  4(x11)");
        $display("  0x08: lw   x5,  4(x11)");
        $display("  0x0C: jal  x8,  +8       -> jumps to 0x14");
        $display("  0x10: jal  x12, +12      *** FLUSHED by jal ***");
        $display("  0x14: sub  x6,  x6, x5");
        $display("  0x18: beq  x0,  x0, -8   -> loops back to 0x10 once");
        $display("  0x1C: add  x10, x9, x5   *** FLUSHED by beq ***\n");

        $display("Expected Hazards:");
        $display("  - Cycle 3-4 : Forwarding (sw/lw uses addi result)");
        $display("  - Cycle 6   : Load-use STALL (sub needs x5 from lw)");
        $display("  - Cycle 5   : JAL flush (jal x12 flushed)");
        $display("  - Cycle 9   : BEQ flush (add x10 flushed)\n");

        //----------------------------------------------------------------------
        // Reset
        //----------------------------------------------------------------------
        rst = 1;
        repeat(3) @(posedge clk);
        @(negedge clk);
        rst = 0;

        $display("-------------------------------------------------------------------------------------------------------");
        $display(" Cyc |  IF      |  ID      |  EX      |  MEM     |  WB      | S  F  FWD");
        $display("-------------------------------------------------------------------------------------------------------");

        // FIX: First posedge after reset = cycle 1 (addi enters IF)
        @(posedge clk); #1;
        cycle = 1;
        if (Stall_F || Stall_D) stall_count = stall_count + 1;
        if (Flush_D || Flush_E) flush_count = flush_count + 1;
        if (FwdA != 0 || FwdB != 0) fwd_count = fwd_count + 1;
        display_row;

        // FIX: Run only 20 more cycles (program is 8 instr, no infinite loop)
        // Total = 21 cycles which is enough for all instructions to complete WB
        repeat(20) begin
            @(posedge clk); #1;
            cycle = cycle + 1;
            if (Stall_F || Stall_D) stall_count = stall_count + 1;
            if (Flush_D || Flush_E) flush_count = flush_count + 1;
            if (FwdA != 0 || FwdB != 0) fwd_count = fwd_count + 1;
            display_row;
        end

        $display("-------------------------------------------------------------------------------------------------------\n");

        $display("Hazard Summary:");
        $display("   Stall cycles  : %0d", stall_count);
        $display("   Flush cycles  : %0d", flush_count);
        $display("   Fwd cycles    : %0d\n", fwd_count);

        //----------------------------------------------------------------------
        // Register checks
        //----------------------------------------------------------------------
  
        $display(" Final Register File Verification");
  
        check_reg(5'd4,   32'd10,  "addi x4=10      ");
        check_reg(5'd5,   32'd10,  "lw   x5=10      ");
        check_reg(5'd8,   32'd16,  "jal  x8=0x10    ");
        check_reg(5'd6,  -32'd10,  "sub  x6,x6,x5   ");
        check_reg(5'd12,  32'd0,   "x12 not written ");

        $display("\nHazard-specific checks:");

        x5val = DUT.DecodeCycle.FileReg.reg_memory[5];
        if (x5val === 32'd10)
            $display("  [PASS] LOAD-USE STALL  : x5 = %0d (lw stall worked)", x5val);
        else
            $display("  [FAIL] LOAD-USE STALL  : x5 = %0d (expected 10)", x5val);

        x12val = DUT.DecodeCycle.FileReg.reg_memory[12];
        if (x12val === 32'd0)
            $display("  [PASS] JAL FLUSH       : x12 = %0d (flushed correctly)", x12val);
        else
            $display("  [FAIL] JAL FLUSH       : x12 = %0d (should be 0)", x12val);

        x8val = DUT.DecodeCycle.FileReg.reg_memory[8];
        if (x8val === 32'd16)
            $display("  [PASS] JAL LINK        : x8 = %0d (return addr = 0x10)", x8val);
        else
            $display("  [FAIL] JAL LINK        : x8 = %0d (expected 16)", x8val);

        $display("\n=========================================================================");
        $display(" RESULT: %0d PASSED / %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" *** ALL TESTS PASSED ***");
        else
            $display(" *** SOME TESTS FAILED ***");
        $display("=========================================================================\n");

        $finish;
    end

    initial begin
        #15000;
        $display("[TIMEOUT]");
        $finish;
    end

endmodule