//work as a sorter to process one sentence of script
//based on the op_code, to use different module
`timescale 1ns/1ps

module AnalyseScript(
    input [15:0] script,//connected to scriptmem's output 
    input clk,
    input res,//use one button or sth to reset pc
    input feedback_sig,//to identify the current state in the kitchen
    input btn_step,//connnect to a button, every time it get pressed pc will move forward one step
    input millisecond_clk,//used by wait     
    output reg [7:0]pc,
    output  [7:0] output_data
);
parameter  enabled = 1'b1,disabled = 1'b0,action_code = 3'b001,jump_code =  3'b010,wait_code = 3'b011,game_code = 3'b100;
//debounced button sig
wire next_step;

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
        .data(target_data)
    );

    // Instantiate TravelerOperateMachine
    TravelerOperateMachine TOM (
        .button_up(sig_move),
        .button_down(sig_throw),
        .button_left(sig_get),
        .button_center(sig_interact),
        .button_right(sig_put),
        .clk(clk),
        .data(operation_data)
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
    .game_state(game_state)
);

//the button is active-high res is active-low
    always @(posedge next_step,posedge res) begin
        if (res) begin
           pc <= 8'b0000_0000; // Reset value of pc
        end
        else
        pc<=pc+2'd2;
    end
endmodule