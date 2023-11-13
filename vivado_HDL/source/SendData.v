// 想要设计成统一处理变化数据并传输给UART的模块

module SendData(
    input [7:0] TravelerTargetMachineData,  // [7:0] 都是数据位 , 选择机器
    input [7:0] GameStateChangeData,        // [7:0] 都是数据位 , 更改游戏状态
    input [8:0] TravelerOperateMachineData, // [8:1]数据为,[0]标记位(标记位用于检测是否多次传输同一数据) , 对机器进行操作
    input uart_clk, // uart时钟周期
    input data_ready,    // 数据是否发送完毕的标志
    output reg [7:0] data_send = 0,   // 接入UART的输出数据
    output reg [7:0] leds = 0   // 测试led灯(显示发送出去的数据信息)
);


reg [7:0] prev_data_gsc = 0;   // 用于保存上一次发送的数据
reg [7:0] prev_data_ttm = 0;   // 用于保存上一次发送的数据
reg [8:0] prev_data_tom = 0;   // 用于保存上一次发送的数据


always @(posedge uart_clk) begin    // 在always块中统一检查数据变化,如果有变化则令output_data设置为当前值
    if(prev_data_ttm!=TravelerTargetMachineData) begin
            prev_data_ttm <= TravelerTargetMachineData;  // 更新保存的数据
            data_send <= TravelerTargetMachineData;   // 向UART传输数据
            leds <= TravelerTargetMachineData;  // led显示发送的数据
    end else if(prev_data_tom!=TravelerOperateMachineData) begin
            prev_data_tom <= TravelerOperateMachineData;
            data_send <= TravelerOperateMachineData[7:0];
            leds <= TravelerOperateMachineData[7:0];
    end else if(prev_data_gsc!=GameStateChangeData) begin
        prev_data_gsc <= GameStateChangeData;
        data_send <= GameStateChangeData;
        leds <= GameStateChangeData;
    end else begin
        if(data_ready) begin
            data_send <= 0;    // 若无数据变化,设置output_data为0,即不通过UART发送数据
        end     
    end
    
end






endmodule