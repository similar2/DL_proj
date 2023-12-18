// 想要设计成统一处理变化数据并传输给UART的模块

module SendData(
    input [7:0] TravelerTargetMachineData,  // [7:0] 选择机器
    input [7:0] GameStateChangeData,        // [7:0] 更改游戏状态
    input [7:0] TravelerOperateMachineData, // [7:0] 机器操作
    input uart_clk, // uart时钟周期
    input data_ready,    // 数据是否发送完毕的标志
    output reg [7:0] data_send = 0,   // 接入UART的输出数据
    output reg [7:0] led = 0
);

parameter SEND_NULL = 2'b00 , SEND_GAMESTATE = 2'b01 , SEND_TARGET = 2'b10 , SEND_OPERATE = 2'b11;


reg [1:0] send_state = SEND_GAMESTATE;
reg [1:0] next_send_state = SEND_TARGET;


// [IMPORTANT]
// When Data = 8'b00000000 , uart will blocking , we must promise the case wont appear

always @(send_state) begin
    case(send_state)
    SEND_GAMESTATE: begin
        data_send = GameStateChangeData;
        next_send_state = SEND_TARGET;
    end
    SEND_TARGET: begin
        data_send = TravelerTargetMachineData;
        next_send_state = SEND_OPERATE;
    end
    SEND_OPERATE: begin
        data_send = TravelerOperateMachineData;
        next_send_state = SEND_GAMESTATE;
    end
    endcase
end


always @(posedge uart_clk) begin
    send_state <= next_send_state;
end







endmodule