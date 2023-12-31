module SendData(
    input [7:0] data_target,        // Data of target machine
    input [7:0] data_game_state,    // Data of game state
    input [7:0] data_operate_verified, // Data of verified operation
    input uart_clk,                 // UART clock
    input data_ready,               // Mark of data send finish
    output reg [7:0] data_send = 0, // Data to send to UART
    output reg [7:0] led = 0        // LED outputs for debugging or indication
);


reg [1:0] send_state = SEND_GAMESTATE;
reg [1:0] next_send_state = SEND_TARGET;

// send FSM (may add script data)
always @(posedge uart_clk) begin
    
        send_state <= next_send_state;
    
end

always @(posedge uart_clk) begin
    
        case(send_state)
            SEND_GAMESTATE: begin
                data_send = data_game_state;
                next_send_state = SEND_TARGET;
            end
            SEND_TARGET: begin
                data_send = data_target;
                next_send_state = SEND_OPERATE;
            end
            SEND_OPERATE: begin
                data_send = data_operate_verified;
                // Ensure data_send is never 0 to avoid UART blocking
                if (data_send == 8'b00000000) begin
                    data_send = 8'b00000001;
                end
                next_send_state = SEND_GAMESTATE;
            end
            default: begin
                data_send = 8'b00000001; // Default to non-zero to avoid UART blocking
                next_send_state = SEND_GAMESTATE;
            end
        endcase
    
end

endmodule
