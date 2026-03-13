module stopwatch_fsm (
    input clk,
    input rst,
    input btn_start_stop, // Should be the debounced signal
    output reg run_en      // High when counter should be ticking
);

    // 1. State Definitions
    localparam S_IDLE    = 2'b00;
    localparam S_RUNNING = 2'b01;
    localparam S_PAUSED  = 2'b10;

    reg [1:0] current_state, next_state;

    // 2. State Register (Sequential)
    always @(posedge clk) begin
        if (rst) 
            current_state <= S_IDLE;
        else 
            current_state <= next_state;
    end

    // 3. Next State Logic (Combinational)
    always @(*) begin
        case (current_state)
            S_IDLE: begin
                run_en = 0;
                if (btn_start_stop) next_state = S_RUNNING;
                else next_state = S_IDLE;
            end
            
            S_RUNNING: begin
                run_en = 1;
                if (btn_start_stop) next_state = S_PAUSED;
                else next_state = S_RUNNING;
            end
            
            S_PAUSED: begin
                run_en = 0;
                if (btn_start_stop) next_state = S_RUNNING;
                else next_state = S_PAUSED;
            end

            default: next_state = S_IDLE;
        endcase
    end
endmodule