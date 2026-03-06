`timescale 1ns/1ps  // Set the time units

module tb_hex();
    reg  [3:0] sw;  // Input to our design (reg because we drive it)
    wire [6:0] seg; // Output from our design

    // Connect the "Device Under Test" (DUT)
    hex_to_7seg dut (
        .hex_digit(sw),
        .seg(seg)
    );

    initial begin
        // Print a header for the console
        $display("Switch | Segments (gfedcba)");
        $display("---------------------------");

        // Test Case 0
        sw = 4'h0; #10; // Set to 0, wait 10 nanoseconds
        $display("  %h    | %b", sw, seg);

        // Test Case 1
        sw = 4'h1; #10;
        $display("  %h    | %b", sw, seg);

        // Test Case 2
        sw = 4'h2; #10;
        $display("  %h    | %b", sw, seg);

        // Test Case 3
        sw = 4'h3; #10;
        $display("  %h    | %b", sw, seg);

        // Test Case 4
        sw = 4'h4; #10;
        $display("  %h    | %b", sw, seg);

        // Test Case 5
        sw = 4'h5; #10;
        $display("  %h    | %b", sw, seg);

        // Test Case 6
        sw = 4'h6; #10;
        $display("  %h    | %b", sw, seg);

        // Test Case 7
        sw = 4'h7; #10;
        $display("  %h    | %b", sw, seg);

        // Test Case 8
        sw = 4'h8; #10;
        $display("  %h    | %b", sw, seg);

        // Test Case 9
        sw = 4'h9; #10;
        $display("  %h    | %b", sw, seg);

        $finish; // End the simulation
    end
endmodule
