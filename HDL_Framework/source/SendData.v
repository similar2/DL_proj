`timescale 1ns/1ps

module SendData(
    input [7:0] data1 = 0,
    input [7:0] data2 = 0,
    input clk,
    input data_in_ready,
    output reg uart_reset,
    output reg [7:0] output_data,
    output reg send_led,
    output reg [7:0] leds
);

reg [7:0] prev_data1;
reg [7:0] prev_data2;

reg start_reset = 0;

always @(posedge clk) begin
    if(start_reset) begin
        uart_reset = 1;
        start_reset = 0;
    end else if(data_in_ready == 1) begin
        uart_reset = 0;
        if(prev_data1!=data1) begin
            leds = data1;
            output_data = data1;
            prev_data1=data1;
            send_led = !send_led;
            start_reset = 1;
        end else if(prev_data2 !=data2) begin
            leds = data2;
            output_data = data2;
            prev_data2=data2;
            send_led = !send_led;
            start_reset = 1;
        end
    end
end

endmodule