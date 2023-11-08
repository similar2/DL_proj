// 想要用来获取UART对应时钟分频的模块
module DivideClock(
    input clk,
    output reg uart_clk = 0,
    output reg second_clk = 0
);

reg [10:0] uart_clk_cnt = 0;
reg [31:0] second_clk_cnt = 0;


always @(posedge clk) begin
    if(uart_clk_cnt < 651) begin
        uart_clk_cnt = uart_clk_cnt + 1;
    end else begin
        uart_clk_cnt = 0;
        uart_clk = !uart_clk;
    end
end

always @(posedge clk) begin
    if(second_clk_cnt < 50000000)
        second_clk_cnt = second_clk_cnt + 1;
    else begin
        second_clk = !second_clk;
        second_clk_cnt = 0;
    end
end

endmodule