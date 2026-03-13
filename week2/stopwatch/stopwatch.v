`timescale 1ns/1ps

module stopwatch #(
    parameter integer TICKS_PER_STEP = 50_000_000
)(
    input  wire clk,
    input  wire rst,
    input  wire run,
    output reg  [3:0] value
);

    reg [31:0] tick_count;

    initial begin
        tick_count = 0;
        value = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            tick_count <= 0;
            value <= 0;
        end else if (run) begin
            if (tick_count == (TICKS_PER_STEP - 1)) begin
                tick_count <= 0;
                if (value == 4'd9)
                    value <= 0;
                else
                    value <= value + 1'b1;
            end else begin
                tick_count <= tick_count + 1'b1;
            end
        end
    end

endmodule