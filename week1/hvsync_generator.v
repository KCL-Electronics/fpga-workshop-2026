// Standard VGA sync generator module (compatible with TinyTapeout)
module hvsync_generator(
    input clk,
    input reset,
    output hsync,
    output vsync,
    output display_on,
    output [9:0] hpos,
    output [9:0] vpos
);

reg [9:0] h_count = 0;
reg [9:0] v_count = 0;

// VGA 640x480 @ 60Hz timing parameters
parameter H_DISPLAY = 640;
parameter H_FRONT = 16;
parameter H_SYNC = 96;
parameter H_BACK = 48;
parameter H_TOTAL = H_DISPLAY + H_FRONT + H_SYNC + H_BACK; // 800

parameter V_DISPLAY = 480;
parameter V_FRONT = 10;
parameter V_SYNC = 2;
parameter V_BACK = 33;
parameter V_TOTAL = V_DISPLAY + V_FRONT + V_SYNC + V_BACK; // 525

always @(posedge clk) begin
    if (reset) begin
        h_count <= 0;
        v_count <= 0;
    end else begin
        if (h_count == H_TOTAL - 1) begin
            h_count <= 0;
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end else begin
            h_count <= h_count + 1;
        end
    end
end

// Generate sync signals (active low)
assign hsync = ~((h_count >= (H_DISPLAY + H_FRONT)) && 
                 (h_count < (H_DISPLAY + H_FRONT + H_SYNC)));
assign vsync = ~((v_count >= (V_DISPLAY + V_FRONT)) && 
                 (v_count < (V_DISPLAY + V_FRONT + V_SYNC)));

// Display active when in visible area
assign display_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);

// Output current position
assign hpos = h_count;
assign vpos = v_count;

endmodule