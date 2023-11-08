// 想要设置成改变任务选择机器的模块
`timescale 1ns/1ps


module ChangeTargetMachine(
    input button_up,
    input button_down,
    input clk,
    output [7:0] output_data
);



reg [5:0] data_7_2 = 0;
reg [1:0] data_channel = 2'b11;
assign output_data = {data_7_2,data_channel};

reg [19:0] button_up_clk_count = 0;     // prevent button shaking 
reg [19:0] button_down_clk_count = 0;
reg prev_button_up = 0;     // record prev button stauts
reg prev_button_down = 0;

always @(posedge clk) begin
    if(!button_up && !button_down) begin
        prev_button_up = 0;
        prev_button_down = 0;
        button_down_clk_count = 0;
        button_up_clk_count = 0;
    end else if(!button_up && button_down) begin
        button_down_clk_count = button_down_clk_count + 1;
        if(button_down_clk_count == 50000) begin
            if(prev_button_down == 0) begin
                if(data_7_2>1) begin
                    data_7_2 = data_7_2 - 1;  
                end else begin
                    data_7_2 = 20;
                end
                prev_button_down = 1;
            end
        end
    end else if(button_up && !button_down) begin
        button_up_clk_count = button_up_clk_count + 1;
        if(button_up_clk_count == 50000) begin
            if(prev_button_up == 0) begin
                if(data_7_2 < 20) begin
                    data_7_2 = data_7_2 + 1;
                end else begin
                    data_7_2 = 1;
                end
                prev_button_up = 1;
            end
        end
    end else begin
        button_down_clk_count = 0;
        button_up_clk_count = 0;
    end
end






endmodule