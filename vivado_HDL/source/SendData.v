// 想要设计成统一处理变化数据并传输给UART的模块

module SendData(
    input uart_clk,
    input test_clk,
    input data_in_ready,
    output reg [7:0] output_data,
    output reg [7:0] leds
);

reg [7:0] data;
reg [7:0] prev_data;



always @(posedge uart_clk) begin
    if(prev_data!=data) begin
        output_data = data;
        prev_data = data;
        leds = prev_data;
    end else begin
        if(data_in_ready==1)
        output_data[1:0] = 2'b00;
    end
    
end

always @(posedge test_clk) begin
    data = data + 1;
end




endmodule