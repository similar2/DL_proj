module TravelerTargetMachine(
    input [4:0] select_switches,
    input clk,
    output reg [8:0] data = 0   // [7:0]是数据位,[8]是标记位(开关默认为0)
);

reg [30:0] clk_cnt = 0; // 防抖计数器
reg [4:0] prev_switch_value = 0;    // 上一次开关值

parameter ANTISHAKECNT = 5000000;   // 用于开关的防抖(常量)

always @(posedge clk) begin
    if(prev_switch_value != select_switches) begin
        prev_switch_value = select_switches;    // 若开关值变化,防抖计数器清零
        clk_cnt = 0;
    end else begin
        if(clk_cnt == ANTISHAKECNT) begin
            if(select_switches>0&&select_switches<21) begin // 限制发送数据范围
                data[6:2] = select_switches;    // 机器编号
                data[1:0] = 2'b11;  // 频道
            end
        end else begin
            clk_cnt = clk_cnt + 1;  // 防抖计数器+1
        end
    end
    
end

endmodule