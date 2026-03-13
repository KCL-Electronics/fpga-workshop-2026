`timescale 1ns/1ps

module hex_to_7seg (
    input [3:0] hex_digit,   // 4 wires coming in (0-15)
    output reg [6:0] seg     // 7 wires going out (a, b, c, d, e, f, g)
);

    // This block "watches" the input wires. 
    // If any wire changes, it re-calculates the output immediately.
    always @(*) begin
        case (hex_digit)
            // Pattern: {g, f, e, d, c, b, a}
            
            // For 0: All outer bars ON, middle bar (g) OFF
            4'h0: seg = 7'b0111111; 
            
            // For 1: Only bars 'b' and 'c' are ON
            4'h1: seg = 7'b0000110; 

            // --- CLASS TASK: FILL IN 2 THROUGH 9 ---
            4'h2: seg = 7'b1011011;
            4'h3: seg = 7'b1001111;
            4'h4: seg = 7'b1100110;
            4'h5: seg = 7'b1101101;
            4'h6: seg = 7'b1111101;
            4'h7: seg = 7'b0000111;
            4'h8: seg = 7'b1111111;
            4'h9: seg = 7'b1101111;
            
            default: seg = 7'b0000000; // Turn everything off if unknown
        endcase
    end

endmodule
