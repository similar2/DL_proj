// 想要作为处理任务与机器交互的模块
`timescale 1ns/1ps

module TravelerOperateMachine(
    input button_up,        // move
    input button_down,      // throw
    input button_left,      // get
    input button_center,    // interact
    input button_right,     // put
    input clk,
    output reg [8:0] data = 0 // [7:0]数据位,[8]标记位
);

parameter ANTISHAKECNT = 5000000;   // 用于按钮的防抖(常量)

reg [30:0] clk_cnt = 0; // 建立计数器记录按钮按下时间
reg [2:0] button_choose = 0;    // 记录按下按钮的id
reg mark = 0;   // mark的作用是用来标记是否多次触发同一个按钮


always@(posedge clk)    // always块中对应五个按钮,原理相同
begin
    data[8] <= mark; // 标记位设置为寄存器变量mark
    if(button_up&&!button_down&&!button_center&&!button_left&&!button_right) begin   // 检测是否为唯一按下按钮
        if(button_choose==1) begin
            if(clk_cnt == ANTISHAKECNT) begin // 当防抖计数器达到设定值,发送数据
                data[7:0] <= 8'bx_01000_10;   // move行为对应的数据
                mark <= !mark;    // 标记位取反,以便于多次触发同一按钮
            end  
            clk_cnt <= clk_cnt + 1;  // 防抖计数器+1
        end else begin
            clk_cnt <= 0;       // 按钮状态变化后,设置防抖计数器值为0
            button_choose <= 1; // 如果按钮id不符合,切换为当前id
        end
    end else if(!button_up&&button_down&&!button_center&&!button_left&&!button_right) begin
       if(button_choose==2) begin
            if(clk_cnt== ANTISHAKECNT) begin
                data[7:0] <= 8'bx_10000_10; 
                mark <=!mark;
            end   
            clk_cnt <= clk_cnt + 1;
        end else begin
            clk_cnt <= 0;
            button_choose <= 2;
        end
    end else if(!button_up&&!button_down&&button_center&&!button_left&&!button_right) begin
         if(button_choose==3) begin
            if(clk_cnt==ANTISHAKECNT) begin
                data[7:0] <= 8'bx_00100_10;
                mark <=!mark;
            end     
            clk_cnt <= clk_cnt + 1;
        end else begin
            clk_cnt <= 0;
            button_choose <= 3;
        end
    end else if(!button_up&&!button_down&&!button_center&&button_left&&!button_right) begin
         if(button_choose==4) begin
            if(clk_cnt==ANTISHAKECNT) begin
                data[7:0] <= 8'bx_00001_10;
                mark <=!mark;
            end
            clk_cnt <= clk_cnt + 1;
        end else begin
            clk_cnt <= 0;
            button_choose <= 4;
        end
    end else if(!button_up&&!button_down&&!button_center&&!button_left&&button_right) begin
         if(button_choose==5) begin
            if(clk_cnt==ANTISHAKECNT) begin
                data[7:0] <= 8'bx_00010_10;
                mark <=!mark;
            end   
            clk_cnt <= clk_cnt + 1;
        end else begin
            clk_cnt <= 0;
            button_choose <= 5;
        end
    end else begin
        button_choose <= 0;  // 按钮闲置状态计数器为0
        clk_cnt <= 0;    // 按钮闲置id设置0
    end
end



endmodule