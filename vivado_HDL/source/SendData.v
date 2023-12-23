// 想要设计成统�?处理变化数据并传输给UART的模�?

module SendData(
    input [7:0] data_target,  // data of target machine
    input [7:0] data_game_state,        // data of game state
    input [7:0] data_operate_verified, // data of verified operate
    input uart_clk, // uart clk
    input data_ready,    // mark of data send finish
    output reg [7:0] data_send = 0,   // data to send to custom
    output reg [7:0] led = 0
);

reg [1:0] send_state = SEND_GAMESTATE;
reg [1:0] next_send_state = SEND_TARGET;


// [IMPORTANT]
// When Data = 8'b00000000 , uart will blocking , we must promise the case wont appear


// send FSM (may add script data)
always @(send_state) begin
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
        next_send_state = SEND_GAMESTATE;
    end
    endcase
end


always @(posedge uart_clk) begin
    send_state <= next_send_state;
end







endmodule