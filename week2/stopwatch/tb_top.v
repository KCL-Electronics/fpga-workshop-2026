`timescale 1ns/1ps

module tb_top();
    // 1. Inputs to 'top' are reg, Outputs are wire
    reg clk;
    reg run;
    reg rst;
    wire [6:0] seg_out;
    reg [3:0] paused_value;

    // 2. Instantiate the TOP module (The whole machine)
    top #(
        .TICKS_PER_STEP(5)
    ) dut (
        .clk(clk),
        .run(run),
        .rst(rst),
        .seg_out(seg_out)
    );

    // 3. Generate the 50MHz Clock (20ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // 4. The Simulation Logic
    initial begin
        clk = 0;
        run = 0;
        rst = 1;

        $dumpfile("tb_top.vcd");
        $dumpvars(0, tb_top);

        $display("Time (ns) | run rst | value | seg (gfedcba)");
        $display("--------------------------------------------");
        $monitor("%8t |  %b   %b  |   %0d   | %b", $time, run, rst, dut.internal_number, seg_out);

        #25 rst = 0;
        #15 run = 1;

        // Let the stopwatch count for a few ticks.
        #420;

        // Pause and confirm the value holds.
        run = 0;
        paused_value = dut.internal_number;
        #200;
        if (dut.internal_number !== paused_value)
            $display("ERROR: Value changed while paused. before=%0d after=%0d", paused_value, dut.internal_number);
        else
            $display("Pause check passed at %t (value=%0d)", $time, dut.internal_number);

        // Reset and verify it returns to zero.
        rst = 1;
        #20;
        rst = 0;
        #20;
        if (dut.internal_number !== 4'd0)
            $display("ERROR: Reset failed, value=%0d", dut.internal_number);
        else
            $display("Reset check passed at %t", $time);

        $display("Simulation complete.");
        $finish;
    end
endmodule