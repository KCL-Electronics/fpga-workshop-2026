module debouncer (
    input clk,
    input btn_in,
    output reg btn_out
);
    reg [19:0] count; 
    reg sync_0, sync_1;

    always @(posedge clk) begin
        sync_0 <= btn_in;   
        sync_1 <= sync_0;   

        if (sync_1 != btn_out) begin
            count <= count + 1;
            if (count == 20'd1_000_000) begin
                btn_out <= sync_1;
                count <= 0;
            end
        end else begin
            count <= 0;
        end
    end
endmodule
