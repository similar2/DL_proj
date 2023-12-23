//work as a sorter to process one sentence of script
//based on the op_code, to use different module
`timescale 1ns/1ps

module AnalyseScript(
    input [15:0] script,//connected to scriptmem's output 
    input clk,
    input res,//use one button or sth to reset pc
    //to identify the current state in the kitchen
    input sig_front,
    input sig_hand,
    input sig_processing,
    input sig_machine,
    input btn_step,//connnect to a button, every time it get pressed pc will move forward one step
    input millisecond_clk,//used by wait     
    input debug_mode,//if this is 1 then we use a button to force pc move forward connected to a switch
    output reg [7:0]pc,
    output  [7:0] data_operate_script,
    output [7:0]data_target_script,
    output [7:0]data_game_state_script
);
parameter  enabled = 1'b1,disabled = 1'b0,action_code = 3'b001,jump_code =  3'b010,wait_code = 3'b011,game_code = 3'b100;
//debounced button sig
wire next_step;
//define feedback sig
//data[7:6]	data[5:2]	data[1:0]	Description
//00	   xxxx	         01	        Traveler targeting on specific machine with ID xxxxxx.
// Description of the signals:
// data[2] - Set(1) when traveler is in front of target machine, otherwise Reset(0).
// data[3] - Set(1) when traveler has item in hand, otherwise Reset(0).
// data[4] - Set(1) when target machine is processing, otherwise Reset(0).
// data[5] - Set(1) when target machine has item, otherwise Reset(0).
wire [7:0] feedback_sig = {2'b00, sig_machine, sig_processing, sig_hand, sig_front, 2'b01};


//divide 16 bit scirpt to 4 parts
wire [7:0] i_num;assign i_num = script[15:8];
wire [2:0] i_sign;assign i_sign = script[7:5];
wire [1:0] func;assign func = script[4:3];
wire [2:0] op_code;assign op_code = script[2:0];
//choose which module to use
wire en_action = disabled,en_jump =disabled,en_wait =disabled,en_game=disabled;

wire [7:0]data_action;
wire [7:0]data_jump;
wire [7:0]data_wait;
wire [7:0]data_game;

//wires for action module
wire [3:0]control_data ;//output of action module consist of 4 enable signal for operate machine
wire sig_move,sig_throw,sig_get,sig_interact,sig_put;
wire [4:0]target_machine;
wire [7:0]target_data;
wire [7:0] operation_data;
//wire for wait
wire is_ready;
//wire for game state change 
wire [7:0] game_state;
//divide control data to 5 parts
assign sig_move = control_data[4];
assign sig_get = control_data[3];
assign sig_put = control_data[2];
assign sig_interact=control_data[1];
assign  sig_throw = control_data[0];
//instantiate debouncer
Debouncer db(
    .clk(clk),
    .btn_input(btn_step),
    .btn_output(next_step)
);
    // Instantiate TravelerTargetMachine
    TravelerTargetMachine TTM (
        .select_switches(target_machine), // Connect the lower 5 bits of i_num
        .clk(clk),
        .data(data_target_script)
    );

    // Instantiate TravelerOperateMachine
    TravelerOperateMachine TOM (
        .button_up(sig_move),
        .button_down(sig_throw),
        .button_left(sig_get),
        .button_center(sig_interact),
        .button_right(sig_put),
        .clk(clk),
        .data(data_operate_script)
    );

jump jump(
    .en(en_jump),
    .clk(clk),
    .i_num(i_num),
    .i_sign(i_sign),
    .next_pc(pc),
    .func(func),
    .feedback_sig(feedback_sig),
    .current_pc(pc)
);
    action act (
        .en(en_action),
        .i_num(i_num),
        .func(func),
        .clk(clk),
        .feedback_sig(feedback_sig),
        .control_data(control_data)
    );
    
Wait wt(
        .en(en_wait),
        .i_num(i_num),
        .func(func),
        .i_sign(i_sign),
        .millisecond_clk(millisecond_clk),
        .clk(clk),
        .feedbak_sig(feedback_sig),
        .is_ready(is_ready)
    );

game_state state(
    .en(en_game),
    .func(func),
    .clk(clk),
    .game_state(data_game_state_script)
);

//the button is active-high res is active-low
    always @(posedge next_step,posedge res) begin
        if (res) begin
           pc <= 8'b0000_0000; // Reset value of pc
        end
        else
        if (debug_mode) begin
              pc<=pc+2'd2;
        end
    end
endmodule