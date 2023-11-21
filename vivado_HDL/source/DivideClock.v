// 想要用来获取UART对应时钟分频的模块
module DivideClock(
    input clk,
    output reg uart_clk = 0,    // UART协议分频
    output reg second_clk = 0,  // 秒分频
    output reg millisecond_clk = 0  // 毫秒分频
);

parameter UARTCNT = 325;
parameter SECONDCNT = 50000000;
parameter MILLISECONDCNT = 50000;

reg [10:0] uart_clk_cnt = 0;    // 分频计数器
reg [31:0] second_clk_cnt = 0;
reg [31:0] millisecond_clk_cnt = 0;

always @(posedge clk) begin
    if(uart_clk_cnt < UARTCNT) begin
        uart_clk_cnt <= uart_clk_cnt + 1;
    end else begin
        uart_clk_cnt <= 0;
        uart_clk <= !uart_clk;
    end
end

always @(posedge clk) begin
    if(second_clk_cnt < SECONDCNT)
        second_clk_cnt = second_clk_cnt + 1;
    else begin
        second_clk = !second_clk;
        second_clk_cnt = 0;
    end
end

always @(posedge clk) begin
    if(millisecond_clk_cnt < MILLISECONDCNT)
        millisecond_clk_cnt = millisecond_clk_cnt + 1;
    else begin
        millisecond_clk = !millisecond_clk;
        millisecond_clk_cnt = 0;
    end
end


endmodule