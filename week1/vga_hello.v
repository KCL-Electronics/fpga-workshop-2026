module vga_hello(
    input wire clk,
    output reg hsync,
    output reg vsync,
    output reg [7:0] r,
    output reg [7:0] g,
    output reg [7:0] b
);
reg [9:0] h = 0;
reg [9:0] v = 0;

always @(posedge clk) begin
    if (h == 799) begin
        h <= 0;
        v <= (v == 524) ? 0 : v + 1;
    end else begin
        h <= h + 1;
    end
    hsync <= ~(h >= 656 && h < 752);
    vsync <= ~(v >= 490 && v < 492);

    if (h < 640 && v < 480) begin
        r <= 8'h00;
        g <= 8'h00;
        b <= 8'hff;
    end else begin
        r <= 0; g <= 0; b <= 0;
    end
end

endmodule
