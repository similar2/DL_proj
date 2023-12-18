module ReceiveUnScriptData(
    input data_valid,
    input [7:0] data_receive,
    input uart_clk,
    input clk,
    output reg sig_front,
    output reg sig_hand,
    output reg sig_processing,
    output reg sig_machine,
    output reg [3:0] feedback_leds = 0
);

parameter MAX = 15;

// 数据不知道为什么会有丢失,排列顺序移动了
// 变成了 ?7654321(0消失了)

// 现在我在UART的receive模块增加了一个寄存位让他恢复了正常,不过我不知道这样做是不是对的(简直泰酷辣)


always @(posedge uart_clk) begin

    if(data_valid) begin


        if(data_receive[1:0]==2'b01) begin
        
            feedback_leds <= data_receive[5:2];
            {sig_machine,sig_processing,sig_hand,sig_front} <= data_receive[5:2];
         
        end else begin

            feedback_leds <= 4'b0000;
            {sig_machine,sig_processing,sig_hand,sig_front} <= 4'b0000;

        end
    
    end

end

endmodule                                                                      