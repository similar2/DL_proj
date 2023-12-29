// `include "Define.v"
module GameStateChange(input switch,
                       input uart_clk,
                       output reg [7:0] data_game_state);
    
    
    
    // use switch to set game state
    always @(switch) begin
        if (switch) begin
            data_game_state = GAME_START;
            end else begin
            data_game_state = GAME_STOP;
        end
    end
    
endmodule
