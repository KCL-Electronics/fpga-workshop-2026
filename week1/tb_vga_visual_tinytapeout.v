module tb_vga_visual_tinytapeout;

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

// Frame buffer for capturing pixels
reg [7:0] frame_buffer [0:640*480*3-1]; // RGB pixels
reg [18:0] pixel_addr = 0; // Address in frame buffer
reg [9:0] pixel_x = 0;
reg [9:0] pixel_y = 0;
reg frame_started = 0;
reg prev_hsync = 1;
reg prev_vsync = 1;

// Track pixel position and capture frame
always @(posedge clk) begin
    if (~rst_n) begin
        pixel_x <= 0;
        pixel_y <= 0;
        frame_started <= 0;
        pixel_addr <= 0;
    end else begin
        // Detect start of frame (vsync falling edge)
        if (prev_vsync && ~vsync && !frame_started) begin
            frame_started <= 1;
            pixel_x <= 0;
            pixel_y <= 0;
            pixel_addr <= 0;
            $display("Frame capture started at time %0t", $time);
        end
        
        // Capture pixels during active video
        if (frame_started && dut.hvsync_gen.display_on) begin
            // Convert 2-bit RGB to 8-bit RGB (scale up)
            frame_buffer[pixel_addr * 3 + 0] <= {R, R, R, R};     // Red
            frame_buffer[pixel_addr * 3 + 1] <= {G, G, G, G};     // Green  
            frame_buffer[pixel_addr * 3 + 2] <= {B, B, B, B};     // Blue
            pixel_addr <= pixel_addr + 1;
            
            // Save frame when we've captured all pixels
            if (pixel_addr >= 640*480 - 1) begin
                #10; // Small delay to let the last pixel complete
                save_frame();
                frame_started <= 0;
            end
        end
        
        prev_hsync <= hsync;
        prev_vsync <= vsync;
    end
end

// Task to save frame buffer as PPM file
task save_frame;
    integer file;
    integer i;
    begin
        file = $fopen("frame_tinytapeout.ppm", "w");
        if (file) begin
            $fwrite(file, "P6\n640 480\n255\n");
            for (i = 0; i < 640*480*3; i = i + 1) begin
                $fwrite(file, "%c", frame_buffer[i]);
            end
            $fclose(file);
            $display("Frame saved to frame_tinytapeout.ppm at time %0t", $time);
            $finish; // Exit after capturing one frame
        end else begin
            $display("Error: Could not open frame_tinytapeout.ppm for writing");
        end
    end
endtask

initial begin
    $dumpfile("vga_tinytapeout_visual.vcd");
    $dumpvars(0, dut);
    
    // Reset pulse
    rst_n = 0;
    #100;
    rst_n = 1;
    
    // Run until frame is captured (task will call $finish)
    #50000000; // Fallback timeout
    $display("Timeout - no frame captured");
    $finish;
end

endmodule