`timescale 1ns/1ps

module tb_counter();
    // 1. Inputs are 'reg', Outputs are 'wire'
    reg clk;
    reg [25:0] count;
    reg [3:0]  value;

    // 2. Generate the Clock (The 50MHz Heartbeat)
    // 50MHz = 20ns period. So we flip the clock every 10ns.
    initial clk = 0;
    always #10 clk = ~clk; 

    // 3. The Logic (Paste your logic here or instantiate your module)
    always @(posedge clk) begin
        if (count == 50_000_000) begin
            count <= 0;
            value <= value + 1;
        end else begin
            count <= count + 1;
        end
    end

    // 4. The Simulation Script
    initial begin
        // Initialize our registers
        count = 0;
        value = 0;

        $display("Time | Count Value | Hex Digit");
        $display("------------------------------");

        // Monitor the values every time 'value' changes
        $monitor("%t | %d | %h", $time, count, value);

        // PROBLEM: Waiting for 50 million cycles takes FOREVER in simulation.
        // Let's cheat for the test and "force" the count to a high number 
        // so we can see the rollover happen quickly.
        #100; 
        count = 49_999_995; 
        
        #200; // Wait a few more clock cycles
        $display("Simulation finished!");
        $finish;
    end
endmodule