module TravelerTargetMachine(
    input [4:0] select_switches,    // 用于选择机器的开关
    input clk,
    output reg [7:0] data  // [7:0]是数据位
);

parameter ANTISHAKECNT = 5000000;   // 用于开关的防抖(常量)

reg [4:0] prev_select_switch = 0;
reg [30:0] clk_cnt = 0; // 建立计数器记录开关拨下时间

// 本来开关我觉得不用防抖,但是FPGA版的2号开关接触不良,碰一下就改状态,会一直发送数据,所以做了一个防抖处理

always @(posedge clk) begin
    if(prev_select_switch == select_switches) begin
        if(clk_cnt == ANTISHAKECNT) begin
            if(select_switches>=1&&select_switches<=20) begin   // 判断机器的id范围
                data[6:2] <= select_switches;    
                data[1:0] <= 2'b11;
            end else begin  // 不添加else锁存器无法正常生成
                data <= 0;
            end
        end else
            clk_cnt <= clk_cnt + 1;
    end else begin
        clk_cnt <= 0;
        prev_select_switch = select_switches;
    end
end

endmodule