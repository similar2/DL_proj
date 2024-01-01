module auto_action(
    input  clk,
    input  enable,
    input [7:0] i_num,
    input  [1:0] func,
    input  [7:0]pc,
    input sig_front,
    input sig_hand,
    input sig_processing,
    input sig_machine,
    output reg [7:0] target_machine = SELECT_DATA_IGNORE,
    output reg [7:0] op_data = OPERATE_IGNORE,
    output reg scriptDonePulse = 0
);

    reg [7:0] last_pc = 8'b0;
    reg [3:0] script_state = SCRIPT_IDLE;
    reg [3:0] next_state = SCRIPT_IDLE;
    reg [3:0] last_state = SCRIPT_IDLE;

    reg PUTChangeFlag = 0;

    always @(posedge clk) begin
        if (!enable|last_pc!=pc) begin
            next_state <= SCRIPT_IDLE;
            scriptDonePulse <= 0;
            PUTChangeFlag <= 0;
        end else begin
            case (next_state)
                SCRIPT_IDLE: begin
                    target_machine <= {1'b0, i_num[4:0], CHANNEL_TARGET}; 
                    case (func)
                        GET:begin
                            if(sig_hand) begin
                                target_machine <= {1'b0, TRASH_BIN_20, CHANNEL_TARGET};
                                op_data <= OPERATE_THROW;
                            end else begin
                                target_machine <= {1'b0, i_num[4:0], CHANNEL_TARGET}; 
                                next_state <= SCRIPT_STARTMOVING;
                            end
                        end
                        PUT,INTERACT: next_state <= SCRIPT_STARTMOVING;
                        THROW:begin
                            case(i_num[4:0])
                                STONE_MILL_7,CUTTING_MACHINE_8,STOVE_10,OVEN_12,OVEN_13,WORKBENCH_15,MIXER_16,CUSTOMER_18:begin
                                    PUTChangeFlag <= 1;
                                    next_state <= SCRIPT_STARTMOVING;
                                end
                                default:next_state <= SCRIPT_DOING;
                            endcase
                        end
                    endcase
                end
                SCRIPT_STARTMOVING:begin
                    op_data <= OPERATE_MOVE;
                    if(!sig_front)next_state <= SCRIPT_MOVING; 
                end
                SCRIPT_MOVING:begin
                    if(sig_front)next_state <= SCRIPT_DOING;
                end
                SCRIPT_DOING: begin
                    case (PUTChangeFlag?PUT:func)
                        GET:begin
                            if(sig_hand)begin 
                                next_state <= SCRIPT_DONE;
                                op_data <= OPERATE_IGNORE;
                            end else op_data <= OPERATE_GET;
                        end
                        PUT:begin
                            if(!sig_hand)begin 
                                next_state <= SCRIPT_DONE;
                                op_data <= OPERATE_IGNORE;
                            end else op_data <= OPERATE_PUT;
                        end
                        INTERACT:begin
                            if(!sig_processing)begin 
                                next_state <= SCRIPT_DONE;
                            end else op_data <= OPERATE_INTERACT;
                        end
                        THROW:begin
                            if(!sig_hand)begin 
                                next_state <= SCRIPT_DONE;
                                op_data <= OPERATE_IGNORE;
                            end else op_data <= OPERATE_THROW;
                        end
                    endcase
                end
            endcase
        end
        last_pc <= pc;
        script_state <= next_state;
        last_state <= script_state;
        scriptDonePulse <= enable&script_state==SCRIPT_DONE&script_state!=last_state;
    end

endmodule



module auto_game_state (
    input  clk,
    input  enable,
    input  [1:0] func,
    input  [7:0]pc,
    output reg [7:0] game_state = GAME_STOP,
    output reg scriptDonePulse = 0
);

    reg [7:0] last_pc = 8'b0;
    reg [3:0] script_state = SCRIPT_IDLE;
    reg [3:0] next_state = SCRIPT_IDLE;
    reg [3:0] last_state = SCRIPT_IDLE;

    always @(posedge clk) begin
        if (!enable|last_pc!=pc) begin
            next_state <= SCRIPT_IDLE;
            scriptDonePulse <= 0;
        end else begin
            case (next_state)
                SCRIPT_IDLE: begin
                    next_state <= SCRIPT_DOING;
                end
                SCRIPT_DOING: begin
                    case (func)
                        game_start: begin
                            game_state <= GAME_START; // 控制gamestart
                            next_state <= SCRIPT_DOING;
                        end
                        game_end: begin
                            game_state <= GAME_STOP; // 控制gameend
                            next_state <= SCRIPT_DOING;
                        end
                    endcase
                    next_state <= SCRIPT_DONE;
                end
            endcase
        end
        last_pc <= pc;
        script_state <= next_state;
        last_state <= script_state;
        scriptDonePulse <= enable&script_state==SCRIPT_DONE&script_state!=last_state;
    end
endmodule


module auto_wait(
    input  clk,
    input millisecond_clk,
    input  enable,
    input [7:0] i_num,
    input  [1:0] func,
    input [2:0] i_sign,
    input  [7:0]pc,
    input sig_front,
    input sig_hand,
    input sig_processing,
    input sig_machine,
    output reg scriptDonePulse = 0
);

    reg [7:0] last_pc = 8'b0;
    reg [3:0] script_state = SCRIPT_IDLE;
    reg [3:0] next_state = SCRIPT_IDLE;
    reg [3:0] last_state = SCRIPT_IDLE;

    reg [9:0]cnt;
    reg waitFlag = 0;
    reg waitDone = 0;
    always@(posedge millisecond_clk)begin
        if(!enable|last_pc!=pc)begin
            waitDone <= 0;
            cnt <= 0;
        end else if(waitFlag)begin
            if(cnt <= i_num * 8'd100)begin
                cnt <= cnt + 1;
            end else waitDone = 1;
        end
    end

    always @(posedge clk) begin
        if (!enable|last_pc!=pc) begin
            next_state <= SCRIPT_IDLE;
            scriptDonePulse <= 0;
            waitFlag <= 0;
        end else begin
            case (next_state)
                SCRIPT_IDLE: begin
                    next_state <= SCRIPT_DOING; 
                end
                SCRIPT_DOING: begin
                    case (func)
                        waituntil_mode:begin
                            case(i_sign)
                                player_ready:begin
                                    if(sig_front)next_state <= SCRIPT_DONE;
                                end
                                player_hasitem:begin
                                    if(sig_hand)next_state <= SCRIPT_DONE;
                                end
                                target_ready:begin
                                    if(sig_processing)next_state <= SCRIPT_DONE;
                                end
                                target_hasitem:begin
                                    if(sig_machine)next_state <= SCRIPT_DONE;
                                end
                            endcase
                        end
                        wait_mode:begin
                            waitFlag <= 1;
                            if(waitDone)next_state <= SCRIPT_DONE;
                        end
                    endcase
                end
            endcase
        end
        last_pc <= pc;
        script_state <= next_state;
        last_state <= script_state;
        scriptDonePulse <= enable&script_state==SCRIPT_DONE&script_state!=last_state;
    end
endmodule


module auto_jump(
    input enable,
    input [7:0] i_num,
    input [1:0] func,
    input [2:0] i_sign,
    input clk,
    input pc,
    input sig_front,
    input sig_hand,
    input sig_processing,
    input sig_machine,
    output reg scriptDonePulse = 0,
    output reg [7:0]jump_num = 1
);

    reg [7:0] last_pc = 8'b0;
    reg [3:0] script_state = SCRIPT_IDLE;
    reg [3:0] next_state = SCRIPT_IDLE;
    reg [3:0] last_state = SCRIPT_IDLE;

    always @(posedge clk) begin
        if (!enable|last_pc!=pc) begin
            next_state <= SCRIPT_IDLE;
            scriptDonePulse <= 0;
            jump_num <= 1;
        end else begin
            case (next_state)
                SCRIPT_IDLE: begin
                    next_state <= SCRIPT_DOING; 
                end
                SCRIPT_DOING: begin
                    case(func)
                        if_mode:begin
                            case(i_sign)
                                player_ready:if(sig_front) jump_num <= i_num;
                                player_hasitem:if(sig_hand) jump_num <= i_num;
                                target_ready:if(sig_processing) jump_num <= i_num;
                                target_hasitem:if(sig_machine) jump_num <= i_num;
                            endcase
                        end
                        ifn_mode:begin
                            case(i_sign)
                                player_ready:if(!sig_front) jump_num <= i_num;
                                player_hasitem:if(!sig_hand) jump_num <= i_num;
                                target_ready:if(!sig_processing) jump_num <= i_num;
                                target_hasitem:if(!sig_machine) jump_num <= i_num;
                            endcase
                        end
                    endcase
                    next_state <=SCRIPT_DONE;
                end
            endcase
        end
        last_pc <= pc;
        script_state <= next_state;
        last_state <= script_state;
        scriptDonePulse <= enable&script_state==SCRIPT_DONE&script_state!=last_state;
    end
endmodule





module delay_by_three_mili_second(
    input clk,            // 时钟信号
    input reset,          // 复位信号
    input pulse_in,       // 原始脉冲信号
    output reg pulse_out  // 延迟后的脉冲信号
);

parameter DELAY_COUNT = 3000; 
reg [19:0] counter = 0; 
reg delay_flag = 0;    
always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 0;
        delay_flag <= 0;
        pulse_out <= 0;
    end else begin
        if (pulse_in && !delay_flag) begin
            delay_flag <= 1;
        end
        if (delay_flag) begin
            if (counter < DELAY_COUNT) begin
                counter <= counter + 1;
            end else begin
                pulse_out <= 1;
                counter <= 0;
                delay_flag <= 0;
            end
        end else begin
            pulse_out <= 0;
        end
    end
end
endmodule