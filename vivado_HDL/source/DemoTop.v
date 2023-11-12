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
        wire uart_clk_16;
        
        wire [7:0] dataIn_bits;
        wire dataIn_ready;
    
        wire [7:0] dataOut_bits;
        wire dataOut_valid;
    
        wire script_mode;
        wire [7:0] pc;
        wire [15:0] script;
// The wire above is useful~

        wire uart_reset = 1'b0;


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


    wire second_clk;
    wire millsecond_clk;

    SendData sd(
      .uart_clk(uart_clk_16),
      .test_clk(millsecond_clk),
      .data_in_ready(dataIn_ready),
      .output_data(dataIn_bits),
      .leds(led)
    );


    DivideClock dc(
      .clk(clk),
      .uart_clk(uart_clk_16),
      .second_clk(second_clk),
      .millsecond_clk(millsecond_clk)
    );

    
endmodule
