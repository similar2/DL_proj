module action(
    input rst,                // Reset input
    input en,
    input [7:0] i_num,
    input [1:0] func,
    input clk,
    input move_ready,
    output reg [7:0] target_machine = SELECT_DATA_IGNORE,
    output reg [7:0] control_data = OPERATE_IGNORE,
    output is_ready
);

    // Internal variables
    reg [7:0] last_i_num = 8'b0;
    reg [1:0] last_func = 2'b0;
    reg input_changed = 0;
    reg [1:0] current_state = IDLE, next_state = IDLE;
    reg [2:0] cnt = 0;
    reg is_ready_action = 0;
    // Assign output
    assign is_ready = is_ready_action;

    // Detect if func or i_num has changed
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            last_i_num <= 8'b0;
            last_func <= 2'b0;
            input_changed <= 1'b0;
            current_state <= IDLE;
        end else begin
            if (i_num != last_i_num || func != last_func) begin
                input_changed <= 1'b1;
                last_i_num <= i_num;
                last_func <= func;
                current_state <= IDLE;
            end else //keep input_changed high for 1 period of FSM
            if (current_state == IDLE) begin
                   input_changed <= 1'b0;
            end
             
        end
    end

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else if (en) begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        if (en) begin
            case (current_state)
                IDLE: begin
                    case (func)
                        GET, PUT, INTERACT: next_state = MOVE; // GET, PUT, INTERACT
                        default: next_state = IDLE;
                    endcase
                end
                MOVE: begin
                    if (move_ready) next_state = ACTION;
                    else next_state = MOVE;
                end
                ACTION: next_state = IDLE;
            endcase
        end 
    end

    // Output logic based on state and inputs
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            target_machine <= SELECT_DATA_IGNORE;
            control_data <= OPERATE_IGNORE;
        end else if (en) begin
            case (current_state)
                IDLE: begin
                    case (func)
                        GET, PUT, INTERACT: begin target_machine = {1'b0, i_num[4:0], CHANNEL_TARGET}; control_data = OPERATE_MOVE; end// GET, PUT, INTERACT
                       THROW: begin // THROW
                            control_data = OPERATE_THROW;
                            target_machine = {1'b0, i_num[4:0], CHANNEL_TARGET};
                        end
                        default: begin
                            control_data = OPERATE_IGNORE;
                            target_machine = SELECT_DATA_IGNORE;
                        end
                    endcase
                end
                MOVE: 
                ACTION:begin
                    case (func)
                        GET: control_data = OPERATE_GET; // GET
                        PUT: control_data = OPERATE_PUT; // PUT
                        INTERACT: control_data = OPERATE_INTERACT; // INTERACT
                        default: control_data = OPERATE_IGNORE;
                    endcase
                end;
            endcase
        end 
    end

    // Logic to update is_ready_action
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            is_ready_action <= 0;
            cnt <= 0;
        end else if (current_state == IDLE && en && input_changed) begin
            cnt <= cnt + 1'b1;
            if (cnt == 3'b010) begin
                is_ready_action <= 1'b1;
                cnt <= 0;
            end else begin
                is_ready_action <= 1'b0;
            end
        end
    end
endmodule
