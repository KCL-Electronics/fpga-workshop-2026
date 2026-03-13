`timescale 1ns/1ps

module tb_stopwatch_fsm();
    reg clk;
    reg rst;
    reg btn_start_stop;
    wire run_en;

    // Instantiate the Unit Under Test (UUT)
    stopwatch_fsm uut (
        .clk(clk),
        .rst(rst),
        .btn_start_stop(btn_start_stop),
        .run_en(run_en)
    );

    // Generate 50MHz clock (20ns period)
    always #10 clk = ~clk;

    initial begin
        // Initialize Signals
        clk = 0;
        rst = 1;
        btn_start_stop = 0;

        // Reset the system
        #100 rst = 0;
        $display("Time: %0t | Reset De-asserted. State: IDLE", $time);

        // Press Start
        #40 btn_start_stop = 1; 
        #20 btn_start_stop = 0; // Release button
        $display("Time: %0t | Button Pressed. State: RUNNING | run_en: %b", $time, run_en);

        // Let it run for a bit
        #100;

        // Press Stop (Pause)
        #20 btn_start_stop = 1;
        #20 btn_start_stop = 0;
        $display("Time: %0t | Button Pressed. State: PAUSED | run_en: %b", $time, run_en);

        // Resume from Pause
        #60 btn_start_stop = 1;
        #20 btn_start_stop = 0;
        $display("Time: %0t | Button Pressed. State: RUNNING | run_en: %b", $time, run_en);

        // Final Reset
        #100 rst = 1;
        #20 rst = 0;
        $display("Time: %0t | Reset Pressed. State: IDLE | run_en: %b", $time, run_en);

        #100 $finish;
    end
endmodule