module tb_vga_image;

    reg clk = 0;
    wire hsync, vsync;
    wire [7:0] r, g, b;

    // instantiate VGA generator
    vga_hello dut (
        .clk(clk),
        .hsync(hsync),
        .vsync(vsync),
        .r(r),
        .g(g),
        .b(b)
    );

    integer x = 0;
    integer y = 0;
    integer file;

    // clock toggle
    always #10 clk = ~clk;  // 50 MHz simulation clock

    initial begin
        // open PPM file
        file = $fopen("frame.ppm", "w");
        // PPM header
        $fwrite(file, "P3\n");
        $fwrite(file, "640 480\n");   // visible resolution
        $fwrite(file, "255\n");
    end

    always @(posedge clk) begin
        // only capture visible pixels
        if (x < 640 && y < 480) begin
            $fwrite(file, "%0d %0d %0d\n", r, g, b);
        end

        // advance pixel counters
        x = x + 1;
        if (x == 800) begin  // total horizontal cycles
            x = 0;
            y = y + 1;
        end

        // finish after one frame
        if (y == 525) begin
            $fclose(file);
            $finish;
        end
    end

endmodule
