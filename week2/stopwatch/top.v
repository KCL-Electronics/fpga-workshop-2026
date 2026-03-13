`timescale 1ns/1ps

module top #(
    parameter integer TICKS_PER_STEP = 50_000_000
)(
    input clk,              // The 50MHz physical pin
    input run,              // Start/stop control
    input rst,              // Synchronous reset
    output [6:0] seg_out    // The 7 physical LED pins
);

    // This is the physical "copper trace" connecting the two modules
    wire [3:0] internal_number;

    // Call the stopwatch counter
    stopwatch #(
        .TICKS_PER_STEP(TICKS_PER_STEP)
    ) my_timer (
        .clk(clk),
        .rst(rst),
        .run(run),
        .value(internal_number) // Output of timer goes TO the wire
    );

    // Call the Decoder
    hex_to_7seg my_display (
        .hex_digit(internal_number), // Input of decoder comes FROM the wire
        .seg(seg_out)
    );

endmodule