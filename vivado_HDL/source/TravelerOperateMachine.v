// 想要作为处理任务与机器交互的模块
`timescale 1ns/1ps

module TravelerOperateMachine(
    input button_up,        // move
    input button_down,      // throw
    input button_left,      // get
    input button_center,    // interact
    input button_right,     // put
    input clk,
    output reg [7:0] data = 0 // [7:0]数据位
);

reg [30:0] clk_cnt = 0; // 建立计数器记录按钮按下时间
parameter ANTISHAKECNT = 5000000;   // 用于按钮的防抖(常量)

reg [7:0] data_prepare;
parameter OPERATE_GET = 8'bx_00001_10 , OPERATE_PUT = 8'bx_00010_10 , OPERATE_INTERACT = 8'bx_00100_10 , OPERATE_MOVE = 8'bx_01000_10 , OPERATE_THROW = 8'bx_10000_10 , OPERATE_NULL = 8'bx_00000_10;

reg [4:0] prev_buttons;
wire [4:0] buttons;
assign buttons = {button_up,button_down,button_center,button_left,button_right};
parameter PRESS_UP = 5'b10000 , PRESS_DOWN = 5'b01000 , PRESS_CENTER = 5'b00100 , PRESS_LEFT = 5'b00010 , PRESS_RIGHT = 5'b00001;

always @(clk_cnt) begin
    if(clk_cnt == ANTISHAKECNT)
        data = data_prepare;
    else
        data = OPERATE_NULL;
end

always @(buttons) begin
    case(buttons)
    PRESS_UP : data_prepare = OPERATE_PUT;
    PRESS_DOWN : data_prepare = OPERATE_THROW;
    PRESS_CENTER : data_prepare = OPERATE_INTERACT;
    PRESS_LEFT : data_prepare = OPERATE_GET;
    PRESS_RIGHT : data_prepare = OPERATE_PUT;
    default : data_prepare = OPERATE_NULL;
    endcase
end

always @(posedge clk) begin
    if(prev_buttons == buttons) begin
        clk_cnt <= clk_cnt + 1;
    end else begin
        clk_cnt <= 0;
        prev_buttons <= buttons;
    end
end


endmodule