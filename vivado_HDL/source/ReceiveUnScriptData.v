module ReceiveUnScriptData(
    input data_valid,
    input [7:0] data_receive,
    input uart_clk,
    input clk,
    output reg  [7:0] feedback_leds
);

parameter MAX = 15;

// 数据不知道为什么会有丢失,排列顺序移动了
// 变成了 ?7654321(0消失了)

reg [7:0] mem_data;


always @(posedge clk) begin
    mem_data <= data_receive;
    feedback_leds <= mem_data;
end

endmodule                                                                      