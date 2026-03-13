`timescale 1ns/1ps

module simple_mux (
    input clk,              // 50MHz
    input [3:0] digit0,     // The number for digit 0 (leftmost)
    input [3:0] digit1,     // The number for digit 1
    input [3:0] digit2,     // The number for digit 2
    input [3:0] digit3,     // The number for digit 3 (rightmost)
    output reg [3:0] hex_to_display, // This goes to your hex_to_7seg decoder
    output reg [3:0] digit_select    // These go to the 'Anode' pins of the display (Active Low, one hot)
);

    // 1. Create a counter that cycles through 4 digits at ~1kHz total
    reg [16:0] count;
    reg [1:0] digit_index;
    
    initial begin
        count = 0;
        digit_index = 0;
    end
    
    always @(posedge clk) begin
        if (count == 17'd12_500) begin // Switch every ~0.25ms (4 digits * 0.25ms = 1ms = 1kHz)
            count <= 0;
            digit_index <= digit_index + 1;
        end else begin
            count <= count + 1;
        end
    end

    // 2. The Multiplexer Logic
    always @(*) begin
        case (digit_index)
            2'b00: begin
                hex_to_display = digit0;
                digit_select = 4'b0111;  // Turn on only digit 0 (Active Low)
            end
            2'b01: begin
                hex_to_display = digit1;
                digit_select = 4'b1011;  // Turn on only digit 1
            end
            2'b10: begin
                hex_to_display = digit2;
                digit_select = 4'b1101;  // Turn on only digit 2
            end
            2'b11: begin
                hex_to_display = digit3;
                digit_select = 4'b1110;  // Turn on only digit 3
            end
        endcase
    end
endmodule
