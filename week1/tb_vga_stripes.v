module tb_vga_stripes;

reg clk = 0;
reg rst_n = 0;
reg [7:0] ui_in = 0;
reg [7:0] uio_in = 0;
wire [7:0] uo_out;
wire [7:0] uio_out;
wire [7:0] uio_oe;
reg ena = 1;

// Instantiate the stripes module
tt_um_vga_example dut(
    .clk(clk),
    .rst_n(rst_n),
    .ui_in(ui_in),
    .uio_in(uio_in),
    .uo_out(uo_out),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(ena)
);

// Extract VGA signals from packed output
wire hsync = uo_out[7];
wire vsync = uo_out[3];
wire [1:0] R = {uo_out[0], uo_out[4]};
wire [1:0] G = {uo_out[1], uo_out[5]};
wire [1:0] B = {uo_out[2], uo_out[6]};

// Generate 25MHz clock
always #20 clk = ~clk; 

initial begin
    $dumpfile("vga_stripes.vcd");
    $dumpvars(0, dut);
    
    // Reset pulse
    rst_n = 0;
    #100;
    rst_n = 1;
    
    // Run simulation - stripes are animated so run longer to see movement
    #5000000;
    $finish;
end

// Display frame info
always @(posedge dut.hvsync_gen.vsync) begin
    $display("Frame at time %0t, counter = %0d", $time, dut.counter);
end

endmodule