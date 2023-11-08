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


    ScriptMem script_mem_module(
      .clock(uart_clk_16),   // please use the same clock as UART module
      .reset(0),           // please use the same reset as UART module
      
      .dataOut_bits(dataOut_bits), // please connect to io_dataOut_bits of UART module
      .dataOut_valid(dataOut_valid), // please connect to io_dataOut_valid of UART module
      
      .script_mode(script_mode), // output 1 when loading script from UART.
                                 // at this time, you should not use dataOut_bits or use pc and script.
      
      .pc(pc), // (a) give a program counter (address) to ScriptMem.
      .script(script) // referring (a), returning the corresponding instructions of pc
    );
        
    UART uart_module(
          .clock(uart_clk_16),     // uart clock. Please use 16 x BultRate. (e.g. 9600 * 16 = 153600Hz
          .reset(0),               // reset
          
          .io_pair_rx(rx),          // rx, connect to R5 please
          .io_pair_tx(tx),         // tx, connect to T4 please
          
          .io_dataIn_bits(dataIn_bits),     // (a) byte from DevelopmentBoard => GenshinKitchen
          .io_dataIn_ready(dataIn_ready),   // referring (a)��pulse 1 after a byte tramsmit success.
          
          .io_dataOut_bits(dataOut_bits),     // (b) byte from GenshinKitchen => DevelopmentBoard, only available if io_dataOut_valid=1
          .io_dataOut_valid(dataOut_valid)  // referring (b)
        );

    wire uart_reset;

    wire 
    traveler_in_front_of_target_machine,
    traveler_has_item_in_hand,
    target_machine_is_processing,
    target_machine_has_item;


    wire [7:0] MachineTargetData;
    wire [7:0] GameStateData;

    wire second_clk;

    ChangeTargetMachine ctm(
      .button_up(button[3]),  
      .button_down(button[1]),
      .clk(clk),
      .output_data(MachineTargetData)
    );

    ChangeGameState cgs(
      .switch_left_0(switches[7]),
      .output_data(GameStateData)
    );


    SendData sd(
      .MachineTargetData(MachineTargetData),
      .GameStateData(GameStateData),
      .uart_clk(uart_clk_16),
      .data_in_ready(dataIn_ready),
      .output_data(dataIn_bits),
      .send_led(led2[0]),
      .ready_led(led2[1]),
      .leds(led)
    );


    DivideClock dc(
      .clk(clk),
      .uart_clk(uart_clk_16),
      .second_clk(second_clk)
    );

    
endmodule
