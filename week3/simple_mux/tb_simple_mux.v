`timescale 1ns/1ps

module tb_simple_mux();
    reg clk;
    reg [3:0] digit0;
    reg [3:0] digit1;
    reg [3:0] digit2;
    reg [3:0] digit3;
    wire [3:0] hex_to_display;
    wire [3:0] digit_select;

    // Instantiate the Mux
    simple_mux uut (
        .clk(clk),
        .digit0(digit0),
        .digit1(digit1),
        .digit2(digit2),
        .digit3(digit3),
        .hex_to_display(hex_to_display),
        .digit_select(digit_select)
    );

    // 50MHz Clock (20ns period)
    always #10 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        digit0 = 4'd0;  // Left
        digit1 = 4'd1;
        digit2 = 4'd2;
        digit3 = 4'd3;  // Right

        $display("Starting 4-Digit Multiplexer Simulation...");
        $display("Time (ns) | Digit_Select (3-0) | Hex Value | Note");
        $display("--------------------------------------------------------");
        
        // Sample through multiple cycles
        // Each digit is active for 0.25ms (250,000 ns)
        #125000;
        $display("%8t |      %b           |    %0d     | Digit 0", $time, digit_select, hex_to_display);
        
        #250000;
        $display("%8t |      %b           |    %0d     | Digit 1", $time, digit_select, hex_to_display);
        
        #250000;
        $display("%8t |      %b           |    %0d     | Digit 2", $time, digit_select, hex_to_display);
        
        #250000;
        $display("%8t |      %b           |    %0d     | Digit 3", $time, digit_select, hex_to_display);
        
        #250000;
        $display("%8t |      %b           |    %0d     | Back to Digit 0", $time, digit_select, hex_to_display);

        $display("Simulation complete.");
        $finish;
    end
endmodule