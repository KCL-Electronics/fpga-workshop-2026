module tb_vga_stripes_visual;

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

// Extract VGA signals
wire hsync = uo_out[7];
wire vsync = uo_out[3];
wire [1:0] R = {uo_out[0], uo_out[4]};
wire [1:0] G = {uo_out[1], uo_out[5]};
wire [1:0] B = {uo_out[2], uo_out[6]};

// Frame capture
integer file;
reg [9:0] x_pos = 0;
reg [9:0] y_pos = 0;
reg frame_capture = 0;
reg [7:0] r_val, g_val, b_val;
integer frame_count = 0;

// Generate 25MHz clock
always #20 clk = ~clk;

// Convert 2-bit to 8-bit color (0->0, 1->85, 2->170, 3->255)
always @(*) begin
    case (R)
        2'b00: r_val = 8'd0;
        2'b01: r_val = 8'd85;
        2'b10: r_val = 8'd170;
        2'b11: r_val = 8'd255;
    endcase
    
    case (G)
        2'b00: g_val = 8'd0;
        2'b01: g_val = 8'd85;
        2'b10: g_val = 8'd170;
        2'b11: g_val = 8'd255;
    endcase
    
    case (B)
        2'b00: b_val = 8'd0;
        2'b01: b_val = 8'd85;
        2'b10: b_val = 8'd170;
        2'b11: b_val = 8'd255;
    endcase
end

// Capture frame
always @(posedge clk) begin
    if (dut.hvsync_gen.display_on && frame_capture) begin
        if (dut.hvsync_gen.hpos < 640 && dut.hvsync_gen.vpos < 480) begin
            $fwrite(file, "%c%c%c", r_val, g_val, b_val);
        end
    end
end

// Task to capture one frame
task capture_frame(input integer frame_num);
    begin
        case (frame_num % 20) // Reduce to 20 frames for manageable output
            0:  file = $fopen("stripes_frame_00.ppm", "wb");
            1:  file = $fopen("stripes_frame_01.ppm", "wb");
            2:  file = $fopen("stripes_frame_02.ppm", "wb");
            3:  file = $fopen("stripes_frame_03.ppm", "wb");
            4:  file = $fopen("stripes_frame_04.ppm", "wb");
            5:  file = $fopen("stripes_frame_05.ppm", "wb");
            6:  file = $fopen("stripes_frame_06.ppm", "wb");
            7:  file = $fopen("stripes_frame_07.ppm", "wb");
            8:  file = $fopen("stripes_frame_08.ppm", "wb");
            9:  file = $fopen("stripes_frame_09.ppm", "wb");
            10: file = $fopen("stripes_frame_10.ppm", "wb");
            11: file = $fopen("stripes_frame_11.ppm", "wb");
            12: file = $fopen("stripes_frame_12.ppm", "wb");
            13: file = $fopen("stripes_frame_13.ppm", "wb");
            14: file = $fopen("stripes_frame_14.ppm", "wb");
            15: file = $fopen("stripes_frame_15.ppm", "wb");
            16: file = $fopen("stripes_frame_16.ppm", "wb");
            17: file = $fopen("stripes_frame_17.ppm", "wb");
            18: file = $fopen("stripes_frame_18.ppm", "wb");
            19: file = $fopen("stripes_frame_19.ppm", "wb");
        endcase
        
        $fwrite(file, "P6\n640 480\n255\n");
        frame_capture = 1;
        
        // Capture one full frame
        @(posedge vsync);
        @(posedge vsync);
        
        frame_capture = 0;
        $fclose(file);
        $display("Frame %0d captured", frame_num % 20);
    end
endtask

// Main test
initial begin
    rst_n = 0;
    #100;
    rst_n = 1;
    
    // Wait for a few frames to let animation develop
    repeat(5) @(posedge vsync);
    
    // Capture 20 frames to see animation
    for (frame_count = 0; frame_count < 20; frame_count = frame_count + 1) begin
        capture_frame(frame_count);
    end
    
    $display("Captured 20 frames: stripes_frame_00.ppm to stripes_frame_19.ppm");
    $finish;
end

endmodule