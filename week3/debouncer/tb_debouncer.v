`timescale 1ns/1ps

module tb_debouncer();
    reg clk;
    reg btn_raw;
    wire btn_stable;

    // Instantiate the debouncer
    // Note: In a real test, you might change the 1_000_000 count 
    // to something smaller (like 10) just for the simulation to run faster.
    debouncer uut (
        .clk(clk),
        .btn_in(btn_raw),
        .btn_out(btn_stable)
    );

    // Generate 50MHz Clock (20ns period)
    always #10 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        btn_raw = 0;
        
        $display("Starting Debouncer Simulation...");
        $monitor("Time: %0t | Raw: %b | Stable: %b", $time, btn_raw, btn_stable);

        #100; // Wait 100ns

        // --- SIMULATE A BOUNCY PRESS ---
        $display("--- Button Pressed (Bouncing) ---");
        btn_raw = 1; #50;   // Bounces to 1
        btn_raw = 0; #40;   // Drops back to 0
        btn_raw = 1; #60;   // Back to 1
        btn_raw = 0; #30;   // Drops back to 0
        
        // --- SETTLE AT 1 ---
        $display("--- Button Settled at 1 ---");
        btn_raw = 1; 

        // Wait long enough for the debouncer to count to 1,000,000
        // (At 20ns per cycle, this takes 20ms)
        #25000000; 

        // --- SIMULATE A BOUNCY RELEASE ---
        $display("--- Button Released (Bouncing) ---");
        btn_raw = 0; #50;
        btn_raw = 1; #40;
        btn_raw = 0; #60;
        btn_raw = 1; #30;

        // --- SETTLE AT 0 ---
        $display("--- Button Settled at 0 ---");
        btn_raw = 0;
        
        #25000000;

        $display("Simulation Finished.");
        $finish;
    end
endmodule