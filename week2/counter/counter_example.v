reg [25:0] count; // Our 26-bit counter
reg [3:0]  value; // The 4-bit number for our 7-seg

always @(posedge clk) begin
    if (count == 50_000_000) begin
        count < = 0;          // Reset counter
        value < = value + 1;  // Increment the display digit
    end else begin
        count < = count + 1;  // Keep waiting
    end
end
