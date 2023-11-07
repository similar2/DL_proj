module TestClock(
    input clk,
    output reg led
);

reg [31:0] cnt_clk = 0;
always @(posedge clk) begin
    if(cnt_clk < 100000000)
        cnt_clk = cnt_clk + 1;
    else begin
        led = ! led;
        cnt_clk = 0;
    end
end
endmodule