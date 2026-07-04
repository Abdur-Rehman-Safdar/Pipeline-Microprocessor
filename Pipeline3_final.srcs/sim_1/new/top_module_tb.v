`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////
// Simple Pipeline Trace Testbench
//
// Har clock cycle yeh batata hai:
//   - Fetch stage mein kaunsi instruction aa rahi hai
//   - Decode stage mein kaunsi instruction hai
//   - Execute / Memory / Writeback stage mein kaunsi instruction hai
// Mnemonic ke sath actual register numbers aur immediate values dikhayi
// jaati hain (jo tumne instruction memory mein likhi thi).
//
// NOTE: Hardware sirf control signals + rd forward karta hai, poora
// instruction word nahi. Isliye yeh testbench apna chhota sa "shadow"
// shift-register rakhta hai jo fetched instruction ko F->D->E->M->W
// stages ke through (no-stall assumption ke sath) le jata hai, sirf
// DISPLAY/trace ke liye.
//////////////////////////////////////////////////////////////////////////

module tb_top_module;

    reg clk, rst;
    integer cycle;

    // Shadow pipeline (sirf instruction word carry karne ke liye, display ke liye)
    reg [31:0] instr_F, instr_D, instr_E, instr_M, instr_W;

    // ---------------- DUT ----------------
    top_module DUT (
        .clk(clk), .rst(rst),
        .pc(), .instruction(), .rs1(), .rs2(), .rd()
    );

    // ---------------- Clock ----------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ---------------- Mnemonic decode task ----------------
    task decode_mnemonic(input [31:0] instr, output [159:0] txt);
        reg [6:0] opcode;
        reg [4:0] rd_f, rs1_f, rs2_f;
        reg signed [11:0] imm;
        begin
            opcode = instr[6:0];
            rd_f   = instr[11:7];
            rs1_f  = instr[19:15];
            rs2_f  = instr[24:20];
            imm    = instr[31:20];
            case(opcode)
                7'b0010011: $sformat(txt, "addi x%0d, x%0d, %0d", rd_f, rs1_f, imm);
                7'b0000011: $sformat(txt, "lw   x%0d, %0d(x%0d)", rd_f, imm, rs1_f);
                7'b0100011: $sformat(txt, "sw   x%0d, %0d(x%0d)", rs2_f, imm, rs1_f);
                7'b0110011: $sformat(txt, "alu  x%0d, x%0d, x%0d", rd_f, rs1_f, rs2_f);
                7'b1100011: $sformat(txt, "beq  x%0d, x%0d", rs1_f, rs2_f);
                7'b1101111: $sformat(txt, "jal  x%0d", rd_f);
                default:    $sformat(txt, "nop / bubble");
            endcase
        end
    endtask

    reg [159:0] txt_F, txt_D, txt_E, txt_M, txt_W;

    // ---------------- Main sequence ----------------
    initial begin
        cycle = 0;
        instr_F = 0; instr_D = 0; instr_E = 0; instr_M = 0; instr_W = 0;

        rst = 1;
        repeat (2) @(posedge clk);
        #1;
        rst = 0;

        $display("\nCyc | FETCH                 | DECODE                | EXECUTE               | MEMORY                | WRITEBACK");
        $display("----|------------------------|------------------------|------------------------|------------------------|------------------------");

        repeat (12) begin
            @(posedge clk);
            #1;
            cycle = cycle + 1;

            // shadow shift forward (back to front so order is correct)
            instr_W = instr_M;
            instr_M = instr_E;
            instr_E = instr_D;
            instr_D = instr_F;
            instr_F = DUT.FetchCycle.ReadData;   // instruction just fetched this cycle

            decode_mnemonic(instr_F, txt_F);
            decode_mnemonic(instr_D, txt_D);
            decode_mnemonic(instr_E, txt_E);
            decode_mnemonic(instr_M, txt_M);
            decode_mnemonic(instr_W, txt_W);

            $display("%30d | %-22s | %-22s | %-22s | %-22s | %-22s",
                      cycle, txt_F, txt_D, txt_E, txt_M, txt_W);
        end

        $display("\n=========== FINAL REGISTER FILE VALUES ===========");
        $display("x5 = %0d   (expected 10)",  DUT.DecodeCycle.FileReg.reg_memory[5]);
        $display("x6 = %0d   (expected -5)",  $signed(DUT.DecodeCycle.FileReg.reg_memory[6]));
        $display("x7 = %0d   (expected 8)",   DUT.DecodeCycle.FileReg.reg_memory[7]);

        $finish;
    end

endmodule