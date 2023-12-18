`timescale 1ns/1ps

module TravelerOperateMachine(
    input button_up,        // move
    input button_down,      // throw
    input button_left,      // get
    input button_center,    // interact
    input button_right,     // put
    input uart_clk,
    output reg [7:0] data_operate = OPERATE_IGNORE // data 
);

// data of operate
parameter OPERATE_GET = 8'b1_00001_10 , OPERATE_PUT = 8'b1_00010_10 , OPERATE_INTERACT = 8'b1_00100_10 , OPERATE_MOVE = 8'b1_01000_10 , OPERATE_THROW = 8'b1_10000_10 , OPERATE_IGNORE = 8'b1_00000_10;

reg [20:0] clk_cnt = 0; // anti shake cnt


reg [7:0] data_store = 0;
reg [4:0] prev_buttons = 0;
wire [4:0] buttons;
assign buttons = {button_up,button_down,button_center,button_left,button_right};

parameter PRESS_UP = 5'b10000 , PRESS_DOWN = 5'b01000 , PRESS_CENTER = 5'b00100 , PRESS_LEFT = 5'b00010 , PRESS_RIGHT = 5'b00001;

// anti-shake constant
parameter ANTISHAKECNT = 15000;

always @(buttons) begin // choose data by buttons
    case(buttons)
        PRESS_UP : data_store = OPERATE_PUT;
        PRESS_DOWN : data_store = OPERATE_THROW;
        PRESS_CENTER : data_store = OPERATE_INTERACT;
        PRESS_LEFT : data_store = OPERATE_GET;
        PRESS_RIGHT : data_store = OPERATE_MOVE;
        default : data_store = OPERATE_IGNORE;
    endcase
end


// get input button , antishake then put to data_operate
always @(posedge uart_clk) begin
    if(prev_buttons == buttons) begin
        clk_cnt <= clk_cnt + 1;
        if(clk_cnt == ANTISHAKECNT) begin
            data_operate <= data_store;
        end     
    end else begin
        clk_cnt <= 0;
        prev_buttons <= buttons;
    end
end




endmodule