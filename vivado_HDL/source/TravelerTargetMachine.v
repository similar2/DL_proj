// `include "Define.v"
module TravelerTargetMachine(
    input [4:0] select_switches,    // switches to represent data_target
    input uart_clk,  // uart_clk to anti-shake
    output reg [7:0] data_target  // return data_target of target machine
);

parameter ANTISHAKECNT = 15000;

parameter SELECT_DATA_IGNORE = 8'b000000_11;
parameter SELECT_VALUE_MAX = 20;
parameter CHANNEL_TARGET = 2'b11;

reg [4:0] prev_select_switch = 0;
reg [30:0] clk_cnt = 0;  // count times when switch change

// anti-shake of switch
always @(clk_cnt) begin
    if(clk_cnt == ANTISHAKECNT) begin
        if(select_switches > SELECT_VALUE_MAX) begin
            data_target = SELECT_DATA_IGNORE;
        end else begin
            data_target = {0,select_switches,CHANNEL_TARGET};
        end
    end
end

always @(posedge uart_clk) begin
    if(prev_select_switch == select_switches) begin
        clk_cnt <= clk_cnt + 1;
    end else begin
        prev_select_switch <= select_switches;
        clk_cnt <= 0;
    end
end


endmodule