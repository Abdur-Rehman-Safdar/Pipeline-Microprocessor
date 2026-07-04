`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////
// Updated Pipeline Trace Testbench
//////////////////////////////////////////////////////////////////////////

module tb_pipeline;

    reg clk, rst;
    integer cycle;

    // Shadow pipeline (sirf instruction word carry karne ke liye, display ke liye)
    reg [31:0] instr_F, instr_D, instr_E, instr_M, instr_W;

    // ---------------- DUT ----------------
    top_module DUT (
        .clk(clk), .rst(rst),
        .pc(), .instruction(), .rs1(), .rs2(), .rd()
    );

    // ---------------- Clock Generator ----------------
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

    // ---------------- Shadow Pipeline Shifting ----------------
    // Isko alag se posedge clk par non-blocking se chalaya hai taake hardware ke sath sync rahe
    always @(posedge clk) begin
        if (rst) begin
            instr_F <= 32'h0;
            instr_D <= 32'h0;
            instr_E <= 32'h0;
            instr_M <= 32'h0;
            instr_W <= 32'h0;
        end else begin
            instr_W <= instr_M;
            instr_M <= instr_E;
            instr_E <= instr_D;
            instr_D <= instr_F;
            // Fetch Cycle se aane wali current instruction directly monitor ho rahi hai
            instr_F <= DUT.FetchCycle.ReadData; 
        end
    end

    // ---------------- Main Sequence & Display ----------------
    initial begin
        cycle = 0;

        // Reset Assert
        rst = 1;
        repeat (2) @(posedge clk);
        
        // Reset Deassert right at the clock edge
        #0.1; 
        rst = 0;

        $display("\nCyc | FETCH                  | DECODE                 | EXECUTE                | MEMORY                 | WRITEBACK");
        $display("----|------------------------|------------------------|------------------------|------------------------|------------------------");

        // 14 cycles run karenge taake pehli instruction completion tak trace ho sake
        repeat (14) begin
            @(posedge clk);
            #1; // Output stabilize hone ka wait (for display only)
            cycle = cycle + 1;

            decode_mnemonic(instr_F, txt_F);
            decode_mnemonic(instr_D, txt_D);
            decode_mnemonic(instr_E, txt_E);
            decode_mnemonic(instr_M, txt_M);
            decode_mnemonic(instr_W, txt_W);

            $display("%3d | %-22s | %-22s | %-22s | %-22s | %-22s",
                      cycle, txt_F, txt_D, txt_E, txt_M, txt_W);
        end

        $display("\n=========== FINAL REGISTER FILE VALUES ===========");
        $display("x5 = %0d   (expected 10)",   DUT.DecodeCycle.FileReg.reg_memory[5]);
        $display("x6 = %0d   (expected -5)",   $signed(DUT.DecodeCycle.FileReg.reg_memory[6]));
        $display("x7 = %0d   (expected 8)",    DUT.DecodeCycle.FileReg.reg_memory[7]);

        $finish;
    end

endmodule