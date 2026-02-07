module tb_vga_tinytapeout;

reg clk = 0;
reg rst_n = 0;
reg [7:0] ui_in = 0;
reg [7:0] uio_in = 0;
wire [7:0] uo_out;
wire [7:0] uio_out;
wire [7:0] uio_oe;
reg ena = 1;

// Instantiate the TinyTapeout VGA module
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

// Generate 25MHz clock (close to VGA pixel clock)
always #20 clk = ~clk; 

initial begin
    $dumpfile("vga_tinytapeout.vcd");
    $dumpvars(0, dut);
    
    // Reset pulse
    rst_n = 0;
    #100;
    rst_n = 1;
    
    // Run for enough time to see several frames
    #2000000;
    $finish;
end

// Optional: Display some info
always @(posedge dut.hvsync_gen.vsync) begin
    $display("New frame at time %0t", $time);
end

endmodule