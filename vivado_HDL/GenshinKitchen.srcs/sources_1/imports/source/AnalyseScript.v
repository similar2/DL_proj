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
    output reg [7:0]pc = 8'b0000_0000,
    output reg [7:0] led,
    output  [7:0] data_operate_script,
    output [7:0]data_target_script,
    output [7:0]data_game_state_script
);

wire next_step;//debounced button sig
wire rst;//debounced reset sig

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
reg en_action = disabled,en_jump =disabled,en_wait =disabled,en_game=disabled;


//wires for action module
wire is_ready_action;
reg  rst_action;
 reg rst_pulse_action;     // Reset pulse that lasts for only one clock cycle
   reg rst_action_reg;  // Register to detect the rising edge
//wire for jump
wire  is_ready_jump;
wire [7:0]next_pc_jump;//next pc address after jumping

//wire for wait
wire  is_ready_wait;
//wire for game state change 
wire [7:0] game_state;

//instantiate debouncer
Debouncer db_step(
    .clk(millisecond_clk),//wait 10ms to debounce
    .btn_input(btn_step),
    .btn_output(next_step)
);
Debouncer db_rst(
    .clk(millisecond_clk),
    .btn_input(res),
    .btn_output(rst)
);   


   
/*if u finish jump module rather than other module, next_pc
 should be the value jump provided (next_pc_jump)
 */
jump jump(
    .en(en_jump),
    .clk(clk),
    .i_num(i_num),
    .i_sign(i_sign),
    .next_pc(next_pc_jump),
    .func(func),
    .is_ready(is_ready_jump),
    .feedback_sig(feedback_sig),
    .current_pc(pc)
);
     action act (
         .en(en_action),
         .i_num(i_num),
         .func(func),
         .clk(clk),
         .rst(rst),
         .move_ready(sig_front),
         .control_data(data_operate_script),
         .target_machine(data_target_script)
     );
    
Wait wt(
        .en(en_wait),
        .i_num(i_num),
        .func(func),
        .i_sign(i_sign),
        .millisecond_clk(millisecond_clk),
        .clk(clk),
        .feedback_sig(feedback_sig),
        .is_ready(is_ready_wait)
    );

game_state state(
    .en(en_game),
    .func(func),
    .clk(clk),
    .game_state(data_game_state_script)
);

//the button is active-high res is active-low
   always @(posedge next_step,posedge rst) begin
       if (rst) begin
          pc <= 8'b0000_0000; // Reset value of pc
       end
       else
       if (debug_mode) begin
               if (is_ready_jump) begin
                   pc<=next_pc_jump;
               end 
               else 
             pc<=pc+2'd2;
       end
   end

always @(op_code) begin
    case (op_code)
       action_code: begin en_action = enabled; en_game = disabled; en_jump = disabled; en_wait = disabled; end
       jump_code: begin en_jump = enabled; en_action = disabled; en_game = disabled; en_wait = disabled; end
       wait_code: begin en_wait = enabled; en_action = disabled; en_game = disabled; en_jump = disabled; end
       game_code: begin en_game = enabled; en_action = disabled; en_jump = disabled; en_wait = disabled; end
       default: begin en_action = disabled; en_game = disabled; en_jump = disabled; en_wait = disabled; end
    endcase
end

endmodule