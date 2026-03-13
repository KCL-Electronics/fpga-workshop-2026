module simple_mux (
    input clk,              // 50MHz
    input [3:0] tens,       // The number for the left digit
    input [3:0] units,      // The number for the right digit
    output reg [3:0] hex_to_display, // This goes to your hex_to_7seg decoder
    output reg [1:0] digit_select    // These go to the 'Anode' pins of the display
);

    // 1. Create a 1kHz switching signal (flicker_clk)
    reg [15:0] count;
    reg flicker_clk;
    
    always @(posedge clk) begin
        if (count == 16'd25_000) begin // Switch every 0.5ms (1kHz total)
            flicker_clk <= ~flicker_clk;
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end

    // 2. The Multiplexer Logic
    always @(*) begin
        if (flicker_clk == 0) begin
            hex_to_display = units;    // Send units to the decoder
            digit_select = 2'b10;      // Turn on only the right digit (Active Low)
        end else begin
            hex_to_display = tens;     // Send tens to the decoder
            digit_select = 2'b01;      // Turn on only the left digit (Active Low)
        end
    end
endmodule
