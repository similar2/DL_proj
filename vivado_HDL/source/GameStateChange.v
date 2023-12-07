// `include "Define.v"
module GameStateChange(
    input switch,
    input [2:0] CompleteCusineNum,
    output reg [7:0] data = 8'bxxxx_10_01
);



always @(switch,CompleteCusineNum) begin
    if(CompleteCusineNum < 3) begin
        if(switch) begin
            data = GAME_START;
        end else begin
            data = GAME_STOP;
        end
    end else begin
        data = GAME_STOP;
    end
end

endmodule