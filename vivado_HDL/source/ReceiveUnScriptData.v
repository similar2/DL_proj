module ReceiveUnScriptData(
    input data_valid,
    input [7:0] data_receive,
    input uart_clk,
    input clk,
    output reg  [3:0] feedback_leds
);

parameter MAX = 15;

// 数据不知道为什么会有丢失,排列顺序移动了
// 变成了 ?7654321(0消失了)

// 现在我在UART的receive模块增加了一个寄存位让他恢复了正常,不过我不知道这样做是不是对的(简直泰酷辣)


always @(posedge clk) begin
    if(data_receive[1:0]==2'b01)
        feedback_leds <= data_receive[5:2];   // led显示反馈数据
    else
        feedback_leds <= 0;                   // 若为脚本模式则全灭
end

endmodule                                                                      