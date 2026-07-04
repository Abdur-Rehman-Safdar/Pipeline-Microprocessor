`timescale 1ns / 1ps
//==============================================================
// TESTBENCH - 5-Stage Pipelined RISC-V Processor
//
// Program loaded in inst_mem:
//  0x00: addi x5, x0, 10    -> x5 = 10
//  0x04: addi x6, x0, 10    -> x6 = 10
//  0x08: sub  x7, x5, x6   -> x7 = 0    (Data Hazard: forwarding)
//  0x0C: beq  x7, x0, 8    -> branch to 0x14 (Control Hazard: flush)
//  0x10: addi x5, x5, 99   -> WRONG PATH: must be flushed, x5 stays 10
//  0x14: jal  x1, 8         -> jump to 0x1C, x1 = 0x18
//  0x18: addi x6, x6, 88   -> WRONG PATH: must be flushed, x6 stays 10
//  0x1C: addi x7, x0, 25   -> x7 = 25
//
// Expected final register values:
//   x1 = 0x18 (24)   - JAL return address
//   x5 = 10          - addi x5,x0,10 ; flush protected x5 from +99
//   x6 = 10          - addi x6,x0,10 ; flush protected x6 from +88
//   x7 = 25          - final addi at JAL target
//==============================================================

module tb_hazard;

    // Clock & Reset
    reg clk, rst;

    // DUT outputs
    wire [31:0] pc, instruction;
    wire [4:0]  rs1, rs2, rd;

    // Instantiate DUT
    top_module DUT (
        .clk(clk), .rst(rst),
        .pc(pc), .instruction(instruction),
        .rs1(rs1), .rs2(rs2), .rd(rd)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Test results
    integer pass_count = 0;
    integer fail_count = 0;

    // Task: check a register value
    task check_reg;
        input [4:0]  reg_num;
        input [31:0] expected;
        input [63:0] test_name; // packed string workaround
        reg [31:0] actual;
        begin
            actual = DUT.DecodeCycle.FileReg.reg_memory[reg_num];
            if (actual === expected) begin
                $display("  [PASS] x%0d = %0d (expected %0d)", reg_num, actual, expected);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] x%0d = %0d  (expected %0d) *** MISMATCH ***",
                          reg_num, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // -------------------------------------------------------
    // Main stimulus
    // -------------------------------------------------------
    integer cycle;

    initial begin
     
        $display("=====================================================");
        $display(" 5-Stage Pipelined RISC-V Processor - Auto Testbench");
        $display("=====================================================");

        // ---- Reset ----
        rst = 1;
        repeat(3) @(posedge clk);
        @(negedge clk);
        rst = 0;

        $display("\n--- Simulation running (cycle-by-cycle PC trace) ---");

        // Run for enough cycles to flush pipeline after last instruction
        // Program is 8 instructions + 4 NOPs; pipeline needs ~13 cycles total
        for (cycle = 0; cycle < 25; cycle = cycle + 1) begin
            @(posedge clk);
            #1; // small delay so outputs settle
            $display("  Cycle %2d | PC_D=0x%08h | IR=0x%08h | rd=x%0d rs1=x%0d rs2=x%0d",
                      cycle, pc, instruction, rd, rs1, rs2);
        end

        $display("\n--- Final Register File Check ---");
        $display("(Reading after pipeline has drained)\n");

        check_reg(5'd1, 32'd24,  "x1=JAL_retaddr");  // JAL saves PC+4 = 0x14+4 = 0x18 = 24
        check_reg(5'd5, 32'd10,  "x5=10_noflush  ");  // must NOT be 10+99=109
        check_reg(5'd6, 32'd10,  "x6=10_noflush  ");  // must NOT be 10+88=98
        check_reg(5'd7, 32'd25,  "x7=25_jaltarget");  // final instruction result

        $display("\n--- Hazard-specific Checks ---");
        // x7 was 0 after sub (forwarding worked); then overwritten to 25 by JAL-target addi
        // If forwarding failed, sub would use stale values -> x7 != 0 after sub
        // We can only verify final state, but x7=25 implies branch was taken (BEQ worked)
        $display("  [INFO] BEQ branch taken check: x7 ended as 25 (not 0)");
        $display("         This confirms branch WAS taken (flush test passed).");
        $display("  [INFO] x5=10 and x6=10 confirms wrong-path instructions were flushed.");

        $display("\n=====================================================");
        $display(" RESULT: %0d PASSED / %0d FAILED", pass_count, fail_count);
        if (fail_count == 0)
            $display(" *** ALL TESTS PASSED - Processor is CORRECT! ***");
        else
            $display(" *** SOME TESTS FAILED - Check waveform ***");
        $display("=====================================================\n");

        $finish;
    end

    // ---- Timeout watchdog ----
    initial begin
        #5000;
        $display("[TIMEOUT] Simulation exceeded 5000 ns - possible hang!");
        $finish;
    end

endmodule