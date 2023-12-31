module actionDebug(
    input rst,                // Reset input
    input en,
    input [7:0] i_num,
    input [1:0] func,
    input clk,
    input move_ready,
    output reg [7:0] target_machine = SELECT_DATA_IGNORE,
    output reg [7:0] control_data = OPERATE_IGNORE // {move, throw, interact, put, get}
);
// wait for 1 clk period before action
reg [15:0] cnt = 0;//cnt for move 
    // Control logic based on input signals
always @(posedge clk,posedge rst) begin
    if (rst) begin
        control_data <= OPERATE_IGNORE; // Reset control_data
        target_machine<=SELECT_DATA_IGNORE;
        cnt <= 0;
    end else if (en) begin 
        // Set target_machine based on input i_num
        target_machine <= {1'b0, i_num[4:0], CHANNEL_TARGET}; 

        // Perform actions based on func
        case (func)
            GET, PUT, INTERACT: begin
                if (cnt < 10000) begin  // Waiting period (10000 cycles) almost 0.001s/1ms
                    control_data <= OPERATE_MOVE; // Move       
                     cnt <= cnt + 1;  // Increment counter each cycle when enabled
//have to explain why set this counter
//for some reasons, move_ready doesn't work well, not because this sig is wrong, but it seems didn't update in time
//so i force before every operation we have to keep sig_move activated for a short time 
//ensure that traveller could move to target machine before operation
//this have neglectable(could be ignored) effect on operation time
//if u have better alternative way to solve this, i will appreciate

                end else if (move_ready) begin
                    // Check if ready to move and perform action
                        case (func)
                            GET: control_data <= OPERATE_GET;        // GET
                            PUT: control_data <= OPERATE_PUT;        // PUT
                            INTERACT: control_data <= OPERATE_INTERACT; // INTERACT
                            default: control_data <= OPERATE_IGNORE;
                        endcase
                end
            end
            THROW: begin
                control_data <= OPERATE_THROW; // Throw
            end
            default: begin
                control_data <= OPERATE_IGNORE; // No action
            end
        endcase
    end else begin
        control_data <= OPERATE_IGNORE; // No action if not enabled
        target_machine<=SELECT_DATA_IGNORE;
        cnt <= 0;  // Reset counter
    end
end

endmodule