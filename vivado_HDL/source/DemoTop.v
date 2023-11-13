// Top文件

`timescale 1ns / 1ps



module DemoTop(
    input [4:0] button,
    input [7:0] switches,

    output [7:0] led,
    output [7:0] led2,
    
    input clk,
    input rx,
    output tx

    );



// The wire below is useful!
        wire uart_clk_16; // UART协议使用时钟周期
        
        wire [7:0] dataIn_bits;
        wire dataIn_ready;
    
        wire [7:0] dataOut_bits;
        wire dataOut_valid;
    
        wire script_mode;
        wire [7:0] pc;
        wire [15:0] script;
// The wire above is useful~

        wire uart_reset = 1'b0; // 没想好是否需要复位,应该不用


    ScriptMem script_mem_module(
      .clock(uart_clk_16),   // please use the same clock as UART module
      .reset(uart_reset),           // please use the same reset as UART module
      
      .dataOut_bits(dataOut_bits), // please connect to io_dataOut_bits of UART module
      .dataOut_valid(dataOut_valid), // please connect to io_dataOut_valid of UART module
      
      .script_mode(script_mode), // output 1 when loading script from UART.
                                 // at this time, you should not use dataOut_bits or use pc and script.
      
      .pc(pc), // (a) give a program counter (address) to ScriptMem.
      .script(script) // referring (a), returning the corresponding instructions of pc
    );
        
    UART uart_module(
          .clock(uart_clk_16),     // uart clock. Please use 16 x BultRate. (e.g. 9600 * 16 = 153600Hz
          .reset(uart_reset),               // reset
          
          .io_pair_rx(rx),          // rx, connect to R5 please
          .io_pair_tx(tx),         // tx, connect to T4 please
          
          .io_dataIn_bits(dataIn_bits),     // (a) byte from DevelopmentBoard => GenshinKitchen
          .io_dataIn_ready(dataIn_ready),   // referring (a)��pulse 1 after a byte tramsmit success.
          
          .io_dataOut_bits(dataOut_bits),     // (b) byte from GenshinKitchen => DevelopmentBoard, only available if io_dataOut_valid=1
          .io_dataOut_valid(dataOut_valid)  // referring (b)
        );

    /* 时钟分频部分 */

    wire second_clk;  // 1秒的时钟分频
    wire millisecond_clk; // 1毫秒的时钟分频

    // 时钟分频
    DivideClock dc(
      .clk(clk),
      .uart_clk(uart_clk_16),   // 时钟分频为UART协议使用的时钟频率
      .second_clk(second_clk),   // 时钟分频至1秒
      .millisecond_clk(millisecond_clk)
    );
    
    /* 发送数据部分 */

    wire [8:0] TravelerOperateMachineData; // 按钮需要标记,最后一位为标记位[8]
    wire [7:0] TravelerTargetMachineData; // 开关不需要标记
    wire [7:0] GameStateChangeData; 

    // 设置游戏状态
    GameStateChange gsc(  
      .switch(switches[7]),
      .data(GameStateChangeData)
    );

    // 玩家操作机器
    TravelerOperateMachine tom(
      .button_up(button[3]),
      .button_down(button[1]),
      .button_center(button[2]),
      .button_left(button[0]),
      .button_right(button[4]),
      .clk(clk),
      .data(TravelerOperateMachineData)
    );

    // 玩家更改目标机器
    TravelerTargetMachine ttm(
        .select_switches(switches[5:0]),
        .data(TravelerTargetMachineData),
        .clk(clk)
    );

    // UART发送数据
    SendData sd(
      .TravelerOperateMachineData(TravelerOperateMachineData),
      .TravelerTargetMachineData(TravelerTargetMachineData),
      .GameStateChangeData(GameStateChangeData),
      .uart_clk(uart_clk_16),
      .data_ready(dataIn_ready),
      .data_send(dataIn_bits),
      .leds(led) // 这个用来显示发送的数据
    );

    /*  接收数据部分  */
    
    // 接受UART返回非脚本数据
    ReceiveUnScriptData rd(
      .data_valid(dataOut_valid),
      .data_receive(dataOut_bits),
      .uart_clk(uart_clk_16),
      .clk(clk),
      .feedback_leds(led2)
    );
    

    
endmodule
