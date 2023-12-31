// 想要用来获取UART对应时钟分频的模�?
module DivideClock(
    input clk,//100Mhz 
    output reg uart_clk = 0,    // uart clk
    output reg second_clk = 0,  // second clk
    output reg millisecond_clk = 0  // millisecond clk
);


// clk counters
reg [10:0] uart_clk_cnt = 0;    
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