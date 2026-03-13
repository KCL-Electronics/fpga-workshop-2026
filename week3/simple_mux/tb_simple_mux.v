`timescale 1ns/1ps

module tb_simple_mux();
    reg clk;
    reg [3:0] tens;
    reg [3:0] units;
    wire [3:0] hex_to_display;
    wire [1:0] digit_select;

    // Instantiate the Mux
    simple_mux uut (
        .clk(clk),
        .tens(tens),
        .units(units),
        .hex_to_display(hex_to_display),
        .digit_select(digit_select)
    );

    // 50MHz Clock (20ns period)
    always #10 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        tens = 4'd1;  // We want to display "1" in the tens place
        units = 4'd2; // We want to display "2" in the units place

        $display("Starting Multiplexer Simulation...");
        
        // Wait for a few flicker cycles
        // Each flicker switch takes 0.5ms (500,000 ns)
        #600000; 
        $display("Check 1: Displaying Digit %b with value %d", digit_select, hex_to_display);
        
        #500000;
        $display("Check 2: Displaying Digit %b with value %d", digit_select, hex_to_display);
        
        #500000;
        $display("Check 3: Displaying Digit %b with value %d", digit_select, hex_to_display);

        $finish;
    end
endmodule