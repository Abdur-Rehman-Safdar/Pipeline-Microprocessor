`timescale 1ns / 1ps

module forward_tb;

// ---------------------------------------------------------------------------
// Clock & Reset
// ---------------------------------------------------------------------------
reg clk, rst;
initial clk = 0;
always #5 clk = ~clk;   // 100 MHz (10ns Period)

// ---------------------------------------------------------------------------
// DUT Instantiation
// ---------------------------------------------------------------------------
wire [31:0] pc_d_top;
wire [31:0] instr_d_top;
wire [4:0]  rs1_top, rs2_top, rd_top;

top_module dut (
    .clk        (clk),
    .rst        (rst),
    .pc         (pc_d_top),
    .instruction(instr_d_top),
    .rs1        (rs1_top),
    .rs2        (rs2_top),
    .rd         (rd_top)
);

// ---------------------------------------------------------------------------
// Hierarchical Wire Taps (Safe from 'Z' or Uninitialized issues)
// ---------------------------------------------------------------------------
wire [31:0] PC_F        = dut.FetchCycle.PC_fetch;
wire [31:0] PC_D        = dut.FetchCycle.PCD;         
wire [31:0] INSTR_D     = dut.FetchCycle.InstrD;      
wire [31:0] PC_E        = dut.DecodeCycle.PC_E;

// neche waali dou lines nahi thein
wire [31:0] PC_M        = (dut.ExecuteCycle.PC_Plus4_M >= 32'd4) ? dut.ExecuteCycle.PC_Plus4_M - 32'd4 : 32'd0;
wire [31:0] PC_W        = (dut.MemCycle.PC_Plus4_W >= 32'd4) ? dut.MemCycle.PC_Plus4_W - 32'd4 : 32'd0;
// Hazard Unit Taps for Forwarding & Stalls
wire [1:0] forward_ae   = dut.Forward_AE;
wire [1:0] forward_be   = dut.Forward_BE;
wire stall_f            = dut.Stall_F;
wire stall_d            = dut.Stall_D;

// Register File Shadow Tap for Auto-Checking
wire [31:0] RF [0:31];
genvar gi;
generate
    for (gi = 0; gi < 32; gi = gi+1) begin : RF_TAP
        assign RF[gi] = dut.DecodeCycle.FileReg.reg_memory[gi];
    end
endgenerate

// ---------------------------------------------------------------------------
// Pipeline Shadow Registers
// ---------------------------------------------------------------------------
reg [31:0] sh_f,  sh_d,  sh_e,  sh_m,  sh_w;
reg        bub_f, bub_d, bub_e, bub_m, bub_w;  

reg [1:0] ann_f, ann_d, ann_e, ann_m, ann_w;
integer cycle_num;

// ---------------------------------------------------------------------------
// Instruction Mnemonic Function (Matches Your Memory Exactly)
// ---------------------------------------------------------------------------
function [22*8-1:0] iname;
    input [31:0] pc;
    input        bubble;
    begin
        if (bubble)
            iname = "[BUBBLE/NOP]          ";
        else case (pc)
            32'd0  : iname = "addi x5, x0, 10       ";
            32'd4  : iname = "addi x6, x5, -5       ";
            32'd8  : iname = "sw   x6, 4(x11)       ";
            32'd12 : iname = "lw   x7, 4(x11)       ";
            32'd16 : iname = "addi x0, x0, 0 (NOP)  ";
            32'd20 : iname = "addi x0, x0, 0 (NOP)  ";
            32'd24 : iname = "addi x0, x0, 0 (NOP)  ";
            default: iname = "Pipeline End/NOP      ";
        endcase
    end
endfunction

// Status String (Stall/Normal)
function [9*8-1:0] ann_str;
    input [1:0] code;
    begin
        case (code)
            2'd1:    ann_str = "(STALL)  ";
            2'd2:    ann_str = "(FLUSHED)";
            default: ann_str = "         ";
        endcase
    end
endfunction

// ---------------------------------------------------------------------------
// Console Table Layout
// ---------------------------------------------------------------------------
task print_header;
    begin
        $display("\n=====================================================================================================================================");
        $display("                                           FORWARDING & PIPELINE STAGE MONITOR");
        $display("=====================================================================================================================================");
        $display("Cyc |     FETCH              |     DECODE             |    EXECUTE             |     MEMORY             |    WRITEBACK           |");
        $display("----+------------------------+------------------------+------------------------+------------------------+------------------------+");
    end
endtask

task print_row;
    reg [9*8-1:0] a_f, a_d, a_e, a_m, a_w;
    begin
        a_f = ann_str(ann_f);
        a_d = ann_str(ann_d);
        a_e = ann_str(ann_e);
        a_m = ann_str(ann_m);
        a_w = ann_str(ann_w);

        $display("%3d | %s%s | %s%s | %s%s | %s%s | %s%s |",
            cycle_num,
            iname(sh_f, bub_f), a_f,
            iname(sh_d, bub_d), a_d,
            iname(sh_e, bub_e), a_e,
            iname(sh_m, bub_m), a_m,
            iname(sh_w, bub_w), a_w
        );
    end
endtask

// ---------------------------------------------------------------------------
// MAIN SIMULATION CONTROL
// ---------------------------------------------------------------------------
initial begin : main_test
    // Initialize
    sh_f = 0; sh_d = 0; sh_e = 0; sh_m = 0; sh_w = 0;
    bub_f=1; bub_d=1; bub_e=1; bub_m=1; bub_w=1;
    ann_f=0; ann_d=0; ann_e=0; ann_m=0; ann_w=0;
    cycle_num = 0;

    // Reset Hardware
    rst = 1;
    repeat(3) @(posedge clk);
    rst = 0;
    @(posedge clk); 

    print_header();

    // Run for 12 cycles to let all 4 instructions execute and pass through Writeback
    repeat (12) begin
        #(0.1); // Dynamic settling time 

        cycle_num = cycle_num + 1;

        // Shift Pipeline Shadows
        sh_w  = sh_m;     bub_w = bub_m;
        sh_m  = sh_e;     bub_m = bub_e;
        sh_e  = sh_d;     bub_e = bub_d;
        sh_d  = sh_f;     bub_d = bub_f;
        sh_f  = PC_F;     bub_f = 0;

        // Annotations for Stalls if any
        ann_f = 0; ann_d = 0; ann_e = 0; ann_m = 0; ann_w = 0;
        if (stall_f) begin ann_f = 1; ann_d = 1; end

        // Print Row
        print_row();

        // FORWARDING LOGS: Jab data forward ho raha ho toh console pr notify kare
        if (forward_ae != 2'b00 && !bub_e) begin
            $display("    [FORWARDING DETECTED] >> Stage EX (RS1) is taking forwarded data. Forward_AE Code = %b", forward_ae);
        end
        if (forward_be != 2'b00 && !bub_e) begin
            $display("    [FORWARDING DETECTED] >> Stage EX (RS2) is taking forwarded data. Forward_BE Code = %b", forward_be);
        end

        @(posedge clk);
    end 

    $display("----+------------------------+------------------------+------------------------+------------------------+------------------------+");
    
    // Final Hardware Register Auto-Checks
    $display("\n=========================================================================================================");
    $display("                                   FINAL HARDWARE REGISTER VALUE CHECK");
    $display("=========================================================================================================");
    check("x5 (addi x5, x0, 10)", 5,  32'd10);
    check("x6 (addi x6, x5, -5)", 6,  32'd5);
    $display("=========================================================================================================\n");
    $finish;
end

// Register Check Task
task check;
    input [24*8-1:0] label;
    input [4:0] rnum;
    input [31:0] expected;
    begin
        if (RF[rnum] === expected)
            $display(" [PASS] %s -> Value in Hardware RF: %0d", label, RF[rnum]);
        else
            $display(" [FAIL] %s -> Value in Hardware RF: %0d (Expected: %0d)", label, RF[rnum], expected);
    end
endtask

endmodule