module action(
    input rst,                // Reset input
    input en,
    input [7:0] i_num,
    input [1:0] func,
    input clk,
    input move_ready,
    output reg [7:0] target_machine,
    output reg [7:0] control_data  // {move, throw, interact, put, get}
);
// wait for 1 clk period before action
reg [2:0] cnt = 0;
    // Control logic based on input signals
always @(posedge clk) begin
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
                if (cnt < 5) begin  // Waiting period (3 cycles)
                    control_data <= OPERATE_MOVE; // Move       
                     cnt <= cnt + 1;  // Increment counter each cycle when enabled
                end else if (cnt >= 5) begin
                    // Check if ready to move and perform action
                    if (move_ready) begin
                        case (func)
                            GET: control_data <= OPERATE_GET;        // GET
                            PUT: control_data <= OPERATE_PUT;        // PUT
                            INTERACT: control_data <= OPERATE_INTERACT; // INTERACT
                            default: control_data <= OPERATE_IGNORE;
                        endcase   
                    end
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
        cnt <= 0;  // Reset counter
    end
end

endmodule
