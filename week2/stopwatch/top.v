module top (
    input clk,              // The 50MHz physical pin
    output [6:0] seg_out    // The 7 physical LED pins
);

    // This is the physical "copper trace" connecting the two modules
    wire [3:0] internal_number;

    // Call the Counter
    counter_example my_timer (
        .clk(clk),
        .value(internal_number) // Output of timer goes TO the wire
    );

    // Call the Decoder
    hex_to_7seg my_display (
        .hex_digit(internal_number), // Input of decoder comes FROM the wire
        .seg(seg_out)
    );

endmodule