module counter_example(
    input  wire clk,
    output reg [3:0] value
);

    reg [25:0] count; // Our 26-bit counter

    initial begin
        count = 0;
        value = 0;
    end

    always @(posedge clk) begin
        if (count == 50_000_000) begin
            count <= 0;          // Reset counter
            value <= value + 1;  // Increment the display digit
        end else begin
            count <= count + 1;  // Keep waiting
        end
    end

endmodule
