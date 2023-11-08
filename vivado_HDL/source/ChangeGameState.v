// 想要设置成改变游戏状态的模块
`timescale 1ns/1ps

module ChangeGameState(
    input switch_left_0,
    output reg [7:0] output_data
);

always@(switch_left_0)
begin
    if(switch_left_0) begin
        output_data = 8'b0000_0101;
    end else begin
        output_data = 8'b0000_1001;
    end
end

endmodule