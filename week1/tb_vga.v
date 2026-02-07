module tb_vga;
reg clk = 0;
wire hsync, vsync;
wire [7:0] r, g, b;

vga_hello dut(.clk(clk), .hsync(hsync), .vsync(vsync), .r(r), .g(g), .b(b));

always #10 clk = ~clk; // 50 MHz sim clock

initial begin
    $dumpfile("vga.vcd");
    $dumpvars(0, dut);
    #2000000 $finish;
end
endmodule
