// Top文件

module DemoTop(
    input [4:0] button,
    input [7:0] switches,

    output [7:0] led,
    output [7:0] led2,
//two buttons for script 


    input clk,
    input rx,
    output tx
    );



// The wire below is useful!
        wire uart_clk_16; // uart clk period
        
        wire [7:0] dataIn_bits;
        wire dataIn_ready;
    
        wire [7:0] dataOut_bits;
        wire dataOut_valid;
    
        wire script_mode;
        wire [7:0] pc;
        wire [15:0] script;
// The wire above is useful~
reg  mode_interpret_script = 0;//set to 1 when interpreting scripts and 0 when manual control or loading scripts
wire [7:0]script_num ;
wire uart_reset = 1'b0; // 没想好是否需要复�???????????,应该不用
wire  res= button[4];//reset pc connected to R11
//we control the datain_bits through the enable sig of senddata module
reg  en_script = 1;
reg  en_manual = 0; 
//wire en_script = mode_interpret_script;
//wire en_manual = mode_interpret_script;
assign led2 =pc;
    ScriptMem script_mem_module(
      .clock(uart_clk_16),   // please use the same clock as UART module
      .reset(uart_reset),           // please use the same reset as UART module
      
      .dataOut_bits(dataOut_bits), // please connect to io_dataOut_bits of UART module
      .dataOut_valid(dataOut_valid), // please connect to io_dataOut_valid of UART module

      .script_mode(script_mode), // output 1 when loading script from UART.
                                 // at this time, you should not use dataOut_bits or use pc and script.
      
      .pc(pc), // (a) give a program counter (address) to ScriptMem.
      .script(script), // referring (a), returning the corresponding instructions of pc
      .script_num(script_num)//size of scripts
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

    wire second_clk;  // clk of 1 second
    wire millisecond_clk; // clk of 1ms

    // 时钟分频
    DivideClock dc(
      .clk(clk),
      .uart_clk(uart_clk_16),   // uart clk
      .second_clk(second_clk),   // 1s clk
      .millisecond_clk(millisecond_clk) // 1ms clk
    );
    

    wire [7:0] data_game_state;        // state of game
    wire [7:0] data_operate; // player origin operate data (receive by buttons)
    wire [7:0] data_operate_verified;  // operate data after verify
    wire [7:0] data_target;  // target machine that player select

    wire sig_front;        // feedback data of player is in front of target machine
    wire sig_hand;                 // feedback of if player has item in hand 
    wire sig_processing;     // feedback of if target machine is processing
    wire sig_machine;          // feedback of if target machine has item

    wire [2:0] cusine_finish_num;       // variable to memory how many cusines finish

    // set data of the state of game
    GameStateChange gsc(  
      .switch(switches[7]),             // left-one switch
      .data_game_state(data_game_state),
      .cusine_finish_num(cusine_finish_num),
      .uart_clk(uart_clk_16)
    );

    // set data of operate (not verified)
    TravelerOperateMachine tom(
      .button_up(button[3]),
      .button_down(button[1]),
      .button_center(button[2]),
      .button_left(button[0]),
      .button_right(button[4]),
      .uart_clk(uart_clk_16),
      .data_operate(data_operate)
    );

    // verified operate data if available
    VerifyIfOperateDataCorrect vod(
      .uart_clk(uart_clk_16),
      .data_game_state(data_game_state),
      .data_operate(data_operate),
      .data_target(data_target),
      .sig_front(sig_front),
      .sig_hand(sig_hand),
      .sig_processing(sig_processing),
      .sig_machine(sig_machine),
      .data_operate_verified(data_operate_verified),
      .data_cusine_finish_num(cusine_finish_num),
      .test_led()
    );

    // set data of target machine
    TravelerTargetMachine ttm(
        .select_switches(switches[5:0]),  // right 5 switches
        .data_target(data_target),
        .uart_clk(uart_clk_16)
    );

    // send data to UART module
    SendData sd(
      // .data_operate_verified(data_operate),
      .enable(en_manual),
      .data_operate_verified(data_operate_verified),
      .data_target(data_target),
      .data_game_state(data_game_state),
      .uart_clk(uart_clk_16),
      .data_ready(dataIn_ready),
      .data_send(dataIn_bits)
    );    
    // receive feedback data of UART
         ReceiveUnScriptData rd(
       .data_valid(dataOut_valid),
       .data_receive(dataOut_bits),
       .uart_clk(uart_clk_16),
       .clk(clk),
       .sig_front(sig_front),
       .sig_hand(sig_hand),
       .sig_processing(sig_processing),
       .sig_machine(sig_machine),
       .feedback_leds(led[3:0]),    // right - 4 led show data
       .led_mode()           // left - 1 led show data

     );
    
//script loading part
wire  [7:0]data_target_script;
wire  [7:0]data_game_state_script;
wire  [7:0]data_operate_script;
wire  [7:0]data_operate_verified_script;

wire  btn_step= button[1];//move forward pc  connected to R17
wire  debug_mode = switches[7];//a switch for script connected to P5 
AnalyseScript AS(
  .script(script),
  .clk(uart_clk_16),
  .res(res),//pc reset sig
  .sig_front(sig_front),
  .sig_hand(sig_hand),
  .sig_machine(sig_machine),
  .sig_processing(sig_processing),
  .btn_step(btn_step),//use a button to move pc forward
  .millisecond_clk(millisecond_clk),
  .pc(pc),
  .debug_mode(debug_mode),
 .data_operate_script(data_operate_script),
   .data_target_script(data_target_script),
    .data_game_state_script(data_game_state_script));

//wires for sccript mode
SendData sd_script(
  .enable(en_script),
      .data_operate_verified(data_operate_verified_script),
      .data_target(data_target_script),
      .data_game_state(data_game_state_script),
      .uart_clk(uart_clk_16),
      .data_ready(dataIn_ready),
      .data_send(dataIn_bits)
);    

    // verified operate data if available
    VerifyIfOperateDataCorrect vod_script(
      .uart_clk(uart_clk_16),
      .data_game_state(data_game_state_script),
      .data_operate(data_operate_script),
      .data_target(data_target_script),
      .sig_front(sig_front),
      .sig_hand(sig_hand),
      .sig_processing(sig_processing),
      .sig_machine(sig_machine),
      .data_operate_verified(data_operate_verified_script),
      .data_cusine_finish_num(cusine_finish_num),
      .test_led()
    );

endmodule
