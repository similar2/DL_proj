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
    output reg scriptDonePulse = 0 //module completion pulse signal
);

//declarations for tracking states and flags
    reg [7:0] last_pc = 8'b0;
    reg [3:0] script_state = SCRIPT_IDLE;
    reg [3:0] next_state = SCRIPT_IDLE;
    reg [3:0] last_state = SCRIPT_IDLE;
    reg PUTChangeFlag = 0;// Flag to indicate a change from THROW to PUT operation.

    always @(posedge clk) begin
        //if the module is disabled or the program counter has changed(means that a new script line is load), reset states and flags
        if (!enable|last_pc!=pc) begin
            next_state <= SCRIPT_IDLE;
            scriptDonePulse <= 0;
            PUTChangeFlag <= 0;
        end else begin
            // state machine handling various script states
            case (next_state)
                SCRIPT_IDLE: begin
                    //change target first
                    target_machine <= {1'b0, i_num[4:0], CHANNEL_TARGET}; 
                    case (func)
                        GET:begin
                            if(sig_hand) begin//error Handling for GET
                                //throw the item in hand first, then sig_hand will turn to 0, we can continue to GET
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
                                    //error Handling for THROW by changing the action to PUT, use a flag to record this change.
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
                    //stay here until move start
                    if(!sig_front)next_state <= SCRIPT_MOVING; 
                end
                SCRIPT_MOVING:begin
                    //stay here until move end
                    if(sig_front)next_state <= SCRIPT_DOING;
                end
                SCRIPT_DOING: begin
                    //check if the THROW Error Handling happens
                    case (PUTChangeFlag?PUT:func)
                        GET:begin
                            if(sig_hand)begin
                                //when sig_hand = 1, the GET operation is done. And we change the operation to ignore
                                next_state <= SCRIPT_DONE;
                                op_data <= OPERATE_IGNORE;
                            end else op_data <= OPERATE_GET;//do
                        end
                        PUT:begin
                            if(!sig_hand)begin 
                                //when sig_hand = 0, the PUT operation is done. And we change the operation to ignore
                                next_state <= SCRIPT_DONE;
                                op_data <= OPERATE_IGNORE;
                            end else op_data <= OPERATE_PUT;//do
                        end
                        INTERACT:begin
                            if(!sig_processing)begin 
                                //when sig_processing = 0, the INTERACT operation is done. And we don't change the operation to ignore, because INTERACT operation is continuous.
                                next_state <= SCRIPT_DONE;
                            end else op_data <= OPERATE_INTERACT;//do
                        end
                        THROW:begin
                            if(!sig_hand)begin 
                                //when sig_hand = 0, the THROW operation is done. And we change the operation to ignore
                                next_state <= SCRIPT_DONE;
                                op_data <= OPERATE_IGNORE;
                            end else op_data <= OPERATE_THROW;//do
                        end
                    endcase
                end
            endcase
        end
        //update the last program counter and script states
        last_pc <= pc;
        script_state <= next_state;
        last_state <= script_state;

        // set the scriptDonePulse based on certain logic
        scriptDonePulse <= enable & script_state==SCRIPT_DONE & script_state!=last_state;
    end

endmodule



module auto_game_state (
    input  clk,
    input  enable,
    input  [1:0] func,
    input  [7:0]pc,
    output reg [7:0] game_state = GAME_STOP,
    output reg scriptDonePulse = 0//module completion pulse signal
);

    //declarations for tracking states
    reg [7:0] last_pc = 8'b0;
    reg [3:0] script_state = SCRIPT_IDLE;
    reg [3:0] next_state = SCRIPT_IDLE;
    reg [3:0] last_state = SCRIPT_IDLE;

    always @(posedge clk) begin
        //if the module is disabled or the program counter has changed(means that a new script line is load), reset states
        if (!enable|last_pc!=pc) begin
            next_state <= SCRIPT_IDLE;
            scriptDonePulse <= 0;
        end else begin
            // state machine handling various script states
            case (next_state)
                SCRIPT_IDLE: begin
                    next_state <= SCRIPT_DOING;
                end
                SCRIPT_DOING: begin
                    case (func)
                        game_start: begin
                            game_state <= GAME_START; // gamestart
                            next_state <= SCRIPT_DOING;
                        end
                        game_end: begin
                            game_state <= GAME_STOP; // gameend
                            next_state <= SCRIPT_DOING;
                        end
                    endcase
                    next_state <= SCRIPT_DONE;
                end
            endcase
        end
        //update the last program counter and script states
        last_pc <= pc;
        script_state <= next_state;
        last_state <= script_state;
        // set the scriptDonePulse based on certain logic
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
    output reg scriptDonePulse = 0//module completion pulse signal
);
//declarations for tracking states and flags
    reg [7:0] last_pc = 8'b0;
    reg [3:0] script_state = SCRIPT_IDLE;
    reg [3:0] next_state = SCRIPT_IDLE;
    reg [3:0] last_state = SCRIPT_IDLE;

    reg [9:0]cnt;// 10-bit counter for timing purposes
    reg waitFlag = 0;// Flag to indicate a when the module should start counting
    reg waitDone = 0;// Flag to indicate when the wait(not waituntil) is complete
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
        //if the module is disabled or the program counter has changed(means that a new script line is load), reset states and flags
        if (!enable|last_pc!=pc) begin
            next_state <= SCRIPT_IDLE;
            scriptDonePulse <= 0;
            waitFlag <= 0;
        end else begin
            // state machine handling various script states
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
                            //change the flag to 1, and wait for waitDone=1
                            waitFlag <= 1;
                            if(waitDone)next_state <= SCRIPT_DONE;
                        end
                    endcase
                end
            endcase
        end
        //update the last program counter and script states
        last_pc <= pc;
        script_state <= next_state;
        last_state <= script_state;
        // set the scriptDonePulse based on certain logic
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
    output reg scriptDonePulse = 0,//module completion pulse signal
    output reg [7:0]jump_num = 1 //the number of lines that need to jump in auto mode
);

//declarations for tracking states
    reg [7:0] last_pc = 8'b0;
    reg [3:0] script_state = SCRIPT_IDLE;
    reg [3:0] next_state = SCRIPT_IDLE;
    reg [3:0] last_state = SCRIPT_IDLE;

    always @(posedge clk) begin
        //if the module is disabled or the program counter has changed(means that a new script line is load), reset states and flags
        if (!enable|last_pc!=pc) begin
            next_state <= SCRIPT_IDLE;
            scriptDonePulse <= 0;
            jump_num <= 1;
        end else begin
            // state machine handling various script states
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
        //update the last program counter and script states
        last_pc <= pc;
        script_state <= next_state;
        last_state <= script_state;
        
        // set the scriptDonePulse based on certain logic
        scriptDonePulse <= enable&script_state==SCRIPT_DONE&script_state!=last_state;
    end
endmodule





module delay_by_twenty_mili_second(
    input clk,            
    input reset,          
    input pulse_in,       
    output reg pulse_out  
);

parameter DELAY_COUNT = 3000; // 3000/(100*(10^6)/635)=0.019s
reg [15:0] counter = 0; // 16-bit counter for timing the delay
reg delay_flag = 0;     // flag to indicate when the module should start counting
always @(posedge clk or posedge reset) begin
    if (reset) begin
        //reset the signals and counter
        counter <= 0;
        delay_flag <= 0;
        pulse_out <= 0;
    end else begin
        if (pulse_in && !delay_flag) begin
            delay_flag <= 1;// set the delay flag to start counting
        end
        if (delay_flag) begin
            if (counter < DELAY_COUNT) begin
                counter <= counter + 1;//increase counter
            end else begin
                pulse_out <= 1;//set the output pulse to 1
                counter <= 0;
                delay_flag <= 0;
            end
        end else begin
            pulse_out <= 0;//set the output pulse to 0 in ordinary times
        end
    end
end
endmodule