module TravelerTargetMachine(
    input [4:0] select_switches,    // 用于选择机器的开关
    input clk,
    output reg [7:0] data  // [7:0]是数据位
);

parameter ANTISHAKECNT = 5000000;   // 用于开关的防抖(常量)
parameter SELECT_IGNORE = 8'b000000_11;
parameter SELECT_VALUE_MAX = 20;
reg [4:0] prev_select_switch = 0;
reg [30:0] clk_cnt = 0; // 建立计数器记录开关拨下时间

// 本来开关我觉得不用防抖,但是FPGA版的2号开关接触不良,碰一下就改状态,会一直发送数据,所以做了一个防抖处理
always @(clk_cnt) begin
    if(clk_cnt == ANTISHAKECNT) begin
        if(select_switches > SELECT_VALUE_MAX) begin
            data = SELECT_IGNORE;
        end else begin
            data = {0,select_switches,2'b11};
        end
    end
end

always @(posedge clk) begin
    if(prev_select_switch == select_switches) begin
        clk_cnt <= clk_cnt + 1;
    end else begin
        prev_select_switch <= select_switches;
        clk_cnt <= 0;
    end
end


endmodule