// `include "Define.v"
module GameStateChange(
    input switch,
    input [2:0] cusine_finish_num,
    input uart_clk,
    output reg [7:0] data_game_state,
    output reg [7:0] test_led = 0
);



// use switch to set game state
always @(switch) begin
    if(switch) begin
        data_game_state = GAME_START;
    end else begin
        data_game_state = GAME_STOP;
    end
end

endmodule