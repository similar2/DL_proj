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
    output reg [7:0]pc = 8'b1111_1111,
    output reg [7:0] led,
    output [7:0] data_operate_script,
    output   [7:0]data_target_script,
    output [7:0]data_game_state_script,
    output led5,
    output  led6,
    output reg led7,
    output [5:0]led50
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
reg en_action_debug = disabled,en_jump_debug =disabled,en_wait_debug =disabled,en_game_debug=disabled;



//wires for action module
wire is_ready_action_debug;
reg rst_action_debug;
reg rst_jump_debug;
reg rst_wait_debug;
reg rst_game_debug;

//these two sig is designed to avoid repeated use of next_pc_jump
//when cnt_execute_jump < cnt_jump and is_ready_jump, it means that last script is jump and pc should be set to where it jump to 
reg [10:0]cnt_jump_debug = 0;//how many "jump"  have been encountered so far
reg [10:0]cnt_execute_jump_debug = 0;//how many times pc jumped so far

//wire for jump
wire  is_ready_jump_debug;
wire [7:0]next_pc_jump_debug;//next pc address after jumping

//wire for wait
wire  is_ready_wait_debug;
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


wire actionDone,stateDone;


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
    .control_data(data_operate_script),
    .target_machine(data_target_script)
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
    .game_state(data_game_state_script)
);



//the button is active-low res is active-low

// always @(posedge clk)begin
//     if(rst_action)begin
//         led6<=1;
//     end else begin
//         if(led6==1)begin
//             cnttemp1<=cnttemp1+1;
//         end
//         if(cnttemp1>100000)begin
//             led6<=0;
//             cnttemp1 <=0;
//         end
//     end

// end
//assign led6 = rst_action;
//assign led7 = actionDone;


reg [7:0]nextpcNormal = 8'b0000_0000;
reg [7:0]nextpcDebug = 8'b1111_1110;

assign led50 = nextpcNormal[5:0];

always @(posedge clk or posedge rst) begin
    if(rst) begin
        pc <= 8'b1111_1110; // 使用非阻塞�?�赋值和复位信号
    end else if (debug_mode) begin
        pc <= nextpcDebug;  // 请确认debug_mode是正确的，并且是同步�??????
    end else begin
        pc <= nextpcNormal;
    end

end

always @(posedge clk or posedge rst) begin   // 确保使用相同的时钟信�?????? `clk`
    if(rst) begin
        nextpcDebug <= 8'b1111_1110;//in debug mode start after click
        nextpcNormal <= 8'b0000_0000;//in normal mode auto start
    end else if (debug_mode && next_step && !next_step_last) begin // 确认实际进入了调试模�??????
        if (is_ready_jump_debug) begin
            nextpcDebug <= next_pc_jump_debug;
            cnt_execute_jump_debug <= cnt_execute_jump_debug + 1;
        end else nextpcDebug <= pc + 2'd2;
    end
end

reg next_step_last; // 用来存储debugModeNextStep的前�??????个状�??????

always @(posedge clk or posedge rst) begin
    if (rst) begin
        next_step_last <= 1'b0;
    end else begin
        next_step_last <= next_step;
    end
end


always @(next_step) begin
    if(next_step)begin
        rst_action_debug = 1;
        rst_jump_debug = 1;
        rst_wait_debug = 1;
        rst_game_debug = 1;
    end else begin
        rst_action_debug = 0;
        rst_jump_debug = 0;
        rst_wait_debug = 0;
        rst_game_debug = 0;
    end
end

always @(op_code) begin
    if(debug_mode)begin
        case (op_code)
            action_code: begin en_action_debug = enabled; en_game_debug = disabled; en_jump_debug = disabled; en_wait_debug = disabled; end
            jump_code: begin en_jump_debug = enabled; en_action_debug = disabled; en_game_debug = disabled; en_wait_debug = disabled; cnt_jump_debug = cnt_jump_debug +1;end
            wait_code: begin en_wait_debug = enabled; en_action_debug = disabled; en_game_debug = disabled; en_jump_debug = disabled; end
            game_code: begin en_game_debug = enabled; en_action_debug = disabled; en_jump_debug = disabled; en_wait_debug = disabled; end
            default: begin en_action_debug = disabled; en_game_debug = disabled; en_jump_debug = disabled; en_wait_debug = disabled; end
        endcase
    end
end

endmodule