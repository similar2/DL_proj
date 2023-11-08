// 想要设计成统一处理变化数据并传输给UART的模块

module SendData(
    input [7:0] MachineTargetData = 0,
    input [7:0] GameStateData = 0,
    input uart_clk,
    input data_in_ready,
    output reg [7:0] output_data,
    output reg uart_reset,
    output reg send_led,
    output reg ready_led,
    output reg [7:0] leds
);

reg [7:0] prev_MachineTarget;
reg [7:0] prev_GameState;


always @(posedge uart_clk) begin
    if(data_in_ready==1) begin
        ready_led = 1;
        if(GameStateData!=prev_GameState) begin
            prev_GameState = GameStateData;
            output_data = GameStateData;
            send_led = !send_led;
        end else if(MachineTargetData!= prev_MachineTarget) begin
            prev_MachineTarget = MachineTargetData;
            output_data = MachineTargetData;
            send_led = !send_led;
        end
        leds = output_data;
    end else begin
        ready_led = 0;
    end
end

endmodule