// `include "Define.v"
module GameStateChange(
    input switch,
    input [2:0] CompleteCusineNum,
    input uart_clk,
    output reg [7:0] data,
    output reg [7:0] led
);

// data of game state
parameter GAME_START = 8'bxxxx_01_01 , GAME_STOP = 8'bxxxx_10_01;  


always @(switch) begin
    if(switch) begin
        data = GAME_START;
    end else begin
        data = GAME_STOP;
    end
end

endmodule