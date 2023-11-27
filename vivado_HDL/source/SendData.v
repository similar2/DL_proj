// 想要设计成统一处理变化数据并传输给UART的模块

module SendData(
    input [7:0] TravelerTargetMachineData,  // [7:0] 选择机器
    input [7:0] GameStateChangeData,        // [7:0] 更改游戏状态
    input [7:0] TravelerOperateMachineData, // [7:0] 机器操作
    input uart_clk, // uart时钟周期
    input data_ready,    // 数据是否发送完毕的标志
    output reg [7:0] data_send = 0   // 接入UART的输出数据
);

parameter SEND_GAMESTATE = 2'b00 , SEND_TARGET = 2'b01 , SEND_OPERATE = 2'b10;


reg [1:0] send_state = 0;

// 示例bit文件的发送数据是轮询，逆天
// 我就说为什么只输出一个数据Move会有问题，byd一直传输不怕给软件整爆了

always @(posedge uart_clk) begin
    case(send_state)
        SEND_GAMESTATE : send_state <= SEND_TARGET;
        SEND_TARGET : send_state <= SEND_OPERATE;
        SEND_OPERATE : send_state <= SEND_GAMESTATE;
    endcase
end

always @(send_state) begin    // 在always块中统一检查数据变化,如果有变化则令output_data设置为当前值
    case(send_state)
        SEND_GAMESTATE : send_data = GameStateChangeData;
        SEND_TARGET : send_data = TravelerTargetMachineData;
        SEND_OPERATE : send_data = TravelerOperateMachineData;
    endcase
end






endmodule