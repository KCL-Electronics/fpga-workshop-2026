`timescale 1ns/1ps

module tb_top();
    // 1. Inputs to 'top' are reg, Outputs are wire
    reg clk;
    wire [6:0] seg_out;

    // 2. Instantiate the TOP module (The whole machine)
    top dut (
        .clk(clk),
        .seg_out(seg_out)
    );

    // 3. Generate the 50MHz Clock (20ns period)
    initial clk = 0;
    always #10 clk = ~clk;

    // 4. The Simulation Logic
    initial begin
        // Let's look at the signals in the terminal
        $display("Time (ns) | Segments (gfedcba) | Note");
        $display("---------------------------------------");
        
        // At 0ns, the counter starts at 0. The segments should show "0"
        #1; 
        $display("%t | %b | Should be '0'", $time, seg_out);

        // --- THE "CHEAT" FOR CLASS ---
        // Instead of waiting 1 second (50,000,000 cycles), 
        // we can use 'force' to jump the internal counter ahead.
        // This is a powerful debugging trick!
        
        #100;
        force dut.my_timer.count = 26'd49_999_998; 
        $display("... Fast-forwarding to nearly 1 second ...");
        
        #60; // Wait 3 clock cycles (20ns * 3 = 60ns)
        
        $display("%t | %b | Should be '1' now!", $time, seg_out);

        #100;
        $display("Simulation complete.");
        $finish;
    end
endmodule