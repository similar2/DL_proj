module DivideClock(
    input clk,
    output reg uart_clk = 0
);

reg [10:0] uart_clk_cnt = 0;



always @(posedge clk) begin
    if(uart_clk_cnt < 651) begin
        uart_clk_cnt = uart_clk_cnt + 1;
    end else begin
        uart_clk_cnt = 0;
        uart_clk = !uart_clk;
    end
end

endmodule