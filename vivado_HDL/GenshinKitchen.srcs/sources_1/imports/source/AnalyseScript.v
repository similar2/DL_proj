//work as a sorter to process one sentence of script
//based on the op_code, to use different module
`timescale 1ns/1ps

module AnalyseScript(
    input [15:0] script,//connected to scriptmem's output 
    input clk,
    input res,//use one button or sth to reset pc
    input stop,
    //to identify the current state in the kitchen
    input sig_front,
    input sig_hand,
    input sig_processing,
    input sig_machine,
    input btn_step,//connnect to a button, every time it get pressed pc will move forward one step
    input millisecond_clk,//used by wait     
    input debug_mode,//if this is 1 then we use a button to force pc move forward connected to a switch
    output reg [7:0]pc = 8'b1111_1110,
    output  [7:0] data_operate_script,
    output  [7:0]data_target_script,
    output  [7:0]data_game_state_script
);

wire next_step;//debounced button sig
wire rst;//debounced reset sig
wire gameStop;assign gameStop = stop;

//define feedback sig
//data[7:6]	data[5:2]	data[1:0]	Description
//00	   xxxx	         01	        Traveler targeting on specific machine with ID xxxxxx.
// Description of the signals:
// data[2] - Set(1) when traveler is in front of target machine, otherwise Reset(0).
// data[3] - Set(1) when traveler has item in hand, otherwise Reset(0).
// data[4] - Set(1) when target machine is processing, otherwise Reset(0).
// data[5] - Set(1) when target machine has item, otherwise Reset(0).
wire [7:0] feedback_sig = {2'b00, sig_machine, sig_processing, sig_hand, sig_front, 2'b01};

//divide 16 bit script to 4 parts
wire [7:0] i_num;assign i_num = script[15:8];
wire [2:0] i_sign;assign i_sign = script[7:5];
wire [1:0] func;assign func = script[4:3];
wire [2:0] op_code;assign op_code = script[2:0];
//choose which module to use
reg en_action_debug = disabled,en_jump_debug =disabled,en_wait_debug =disabled,en_game_debug=disabled;
reg en_action = disabled,en_jump =disabled,en_wait=disabled ,en_game=disabled;


//wires for preliminary outputs in debug/auto modes
wire [7:0]data_operate_script_debug, data_operate_script_auto;
wire [7:0]data_target_script_debug, data_target_script_auto;
wire [7:0]data_game_state_script_debug,data_game_state_script_auto;

//Select output data based on game state and debug/auto mode
assign data_operate_script = (data_game_state_script==GAME_STOP)?OPERATE_IGNORE:((debug_mode)?data_operate_script_debug:data_operate_script_auto);
assign data_target_script = (data_game_state_script==GAME_STOP)?SELECT_DATA_IGNORE:((debug_mode)?data_target_script_debug:data_target_script_auto);
assign data_game_state_script = (gameStop)?GAME_STOP:((debug_mode)?data_game_state_script_debug:data_game_state_script_auto);


//wires for action module in debug mode
wire is_ready_action_debug;
wire rst_action_debug;
wire rst_jump_debug;
wire rst_wait_debug;
wire rst_game_debug;

//these two sig is designed to avoid repeated use of next_pc_jump
//when cnt_execute_jump < cnt_jump and is_ready_jump, it means that last script is jump and pc should be set to where it jump to 
reg [10:0]cnt_jump_debug = 0;//how many "jump"  have been encountered so far
reg [10:0]cnt_execute_jump_debug = 0;//how many times pc jumped so far



//wire for jump
wire  is_ready_jump_debug;
wire [7:0]next_pc_jump_debug;//next pc address after jumping

//wire for wait
wire  is_ready_wait_debug;


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
jumpDebug jump(
    .en(en_jump_debug),
    .clk(clk),
    .i_num(i_num),
    .i_sign(i_sign),
    .next_pc(next_pc_jump_debug),
    .func(func),
    .is_ready(is_ready_jump_debug),
    .feedback_sig(feedback_sig),
    .current_pc(pc)
);
actionDebug act (
    .en(en_action_debug),
    .i_num(i_num),
    .func(func),
    .clk(clk),
    .rst(rst_action_debug),
    .move_ready(sig_front),
    .control_data(data_operate_script_debug),
    .target_machine(data_target_script_debug)
);
    
WaitDebug wt(
    .en(en_wait_debug),
    .i_num(i_num),
    .func(func),
    .i_sign(i_sign),
    .millisecond_clk(millisecond_clk),
    .clk(clk),
    .feedback_sig(feedback_sig),
    .is_ready(is_ready_wait_debug)
);

game_stateDebug state(
    .en(en_game_debug),
    .func(func),
    .clk(clk),
    .game_state(data_game_state_script_debug)
);



//wires for auto modules completion pulse signal
wire agsDonePulse;
wire aactDonePulse;
wire awtDonePulse;
wire ajDonePulse;
//wires for the number of lines that need to jump in auto mode
wire [7:0]jumpNum;


auto_game_state ags(
    .enable(en_game),
    .func(func),
    .pc(pc),
    .clk(clk),
    .game_state(data_game_state_script_auto),
    .scriptDonePulse(agsDonePulse)
);

auto_action aact(
    .clk(clk),
    .enable(en_action),
    .i_num(i_num),
    .func(func),
    .pc(pc),
    .sig_front(sig_front),
    .sig_hand(sig_hand),
    .sig_processing(sig_processing),
    .sig_machine(sig_machine),
    .target_machine(data_target_script_auto),
    .op_data(data_operate_script_auto),
    .scriptDonePulse(aactDonePulse)
);

auto_wait awt(
    .clk(clk),
    .millisecond_clk(millisecond_clk),
    .enable(en_wait),
    .i_num(i_num),
    .func(func),
    .i_sign(i_sign),
    .pc(pc),
    .sig_front(sig_front),
    .sig_hand(sig_hand),
    .sig_processing(sig_processing),
    .sig_machine(sig_machine),
    .scriptDonePulse(awtDonePulse)
);

auto_jump aj(
    .enable(en_jump),
    .i_num(i_num),
    .func(func),
    .i_sign(i_sign),
    .clk(clk),
    .pc(pc),
    .sig_front(sig_front),
    .sig_hand(sig_hand),
    .sig_processing(sig_processing),
    .sig_machine(sig_machine),
    .scriptDonePulse(ajDonePulse),
    .jump_num(jumpNum)
);


//signal indicating that the next step can be performed
wire autoNext;assign autoNext = (en_game&agsDonePulse)|(en_action&aactDonePulse)|(en_wait&awtDonePulse)|(en_jump&ajDonePulse);
//for the stability of script execution, we delay the autoNext signal by 20ms
wire autoNextDelay;

delay_by_twenty_mili_second delay(
    .clk(clk),
    .pulse_in(autoNext),
    .pulse_out(autoNextDelay)
);

//the next pc in normal(auto) mode, with the initial value 8'b0000_0000.the scripts will auto start
reg [7:0]nextpcNormal = 8'b0000_0000;

//the next pc in debug mode, with the initial value 8'b1111_1110,the game will start after click the button
reg [7:0]nextpcDebug = 8'b1111_1110;


//define the update logic for pc
always @(posedge clk or posedge rst or posedge gameStop) begin
    if(rst|gameStop) begin
        pc <= 8'b1111_1110; 
    end else if (debug_mode) begin
        pc <= nextpcDebug;  
    end else begin
        pc <= nextpcNormal;
    end
end


//define the update logic for nextpcNormal
always @(posedge clk or posedge rst)begin
    if(rst)begin
        nextpcNormal <= 8'b0000_0000;
    end else if(!debug_mode && autoNextDelay)begin
        //when enjump is 1, nextpcNormal will add by jumpNum*2'd2
        nextpcNormal <= nextpcNormal +(en_jump?jumpNum*2'd2:2'd2);
    end
end


always @(posedge clk or posedge rst) begin
    if(rst) begin
        nextpcDebug <= 8'b1111_1110;//in debug mode start after click
    end else if (debug_mode && next_step && !next_step_last) begin 
         //when is_ready_jump_debug is 1, nextpcNormal will stay still until is_ready_jump_debug turns 0
        if (is_ready_jump_debug) begin
            nextpcDebug <= next_pc_jump_debug;
            cnt_execute_jump_debug <= cnt_execute_jump_debug + 1;
        end else nextpcDebug <= nextpcDebug + 2'd2;
    end
end

//record the last next_step, in order to judge next_step's rise in the always block 
reg next_step_last; 
always @(posedge clk or posedge rst) begin
    if (rst) begin
        next_step_last <= 1'b0;
    end else begin
        next_step_last <= next_step;
    end
end

//in debug mode, if the next button is clicked, the reset signals in debug mode will also be enabled
assign rst_action_debug = next_step;
assign rst_jump_debug = next_step;
assign rst_wait_debug = next_step;
assign rst_game_debug = next_step;


//select the enabled module based on the opcode
always @(op_code) begin
    if(debug_mode)begin
        case (op_code)
            action_code: begin en_action_debug = enabled; en_game_debug = disabled; en_jump_debug = disabled; en_wait_debug = disabled; end
            jump_code: begin en_jump_debug = enabled; en_action_debug = disabled; en_game_debug = disabled; en_wait_debug = disabled; cnt_jump_debug = cnt_jump_debug +1;end
            wait_code: begin en_wait_debug = enabled; en_action_debug = disabled; en_game_debug = disabled; en_jump_debug = disabled; end
            game_code: begin en_game_debug = enabled; en_action_debug = disabled; en_jump_debug = disabled; en_wait_debug = disabled; end
            default: begin en_action_debug = disabled; en_game_debug = disabled; en_jump_debug = disabled; en_wait_debug = disabled; end
        endcase
    end else begin
        case (op_code)
            action_code: begin en_action= enabled; en_game = disabled; en_jump = disabled; en_wait = disabled; end
            jump_code: begin en_action= disabled; en_game = disabled; en_jump = enabled; en_wait = disabled;end
            wait_code: begin en_action= disabled; en_game = disabled; en_jump = disabled; en_wait = enabled;  end
            game_code: begin en_action= disabled; en_game = enabled; en_jump = disabled; en_wait = disabled;  end
            default: begin en_action= disabled; en_game = disabled; en_jump = disabled; en_wait = disabled;  end
        endcase
    end
end

endmodule