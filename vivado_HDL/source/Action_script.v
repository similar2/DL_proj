module action(
    input en,
    input [7:0] i_num,
    input [1:0] func,
    input clk,
    input  rst, 
    input move_ready,
    output reg [7:0] target_machine,
    output reg [4:0] control_data // {move, throw, interact, put, get}
);

    always @(posedge clk) begin
        if (rst) begin
            // Reset logic
            control_data <= 5'b00000;
            target_machine <= 8'b0000_0000;
        end else if (en) begin
            target_machine <= i_num;
            case (func)
                GET, PUT, INTERACT: begin
                    control_data <= 5'b10000; // Move
                    if (move_ready) begin
                        case (func)
                            GET: control_data <= 5'b00001;
                            PUT: control_data <= 5'b00010;
                            INTERACT: control_data <= 5'b00100;
                        endcase
                    end
                end
                THROW: control_data <= 5'b01000; // Throw
                default: control_data <= 5'b00000; // No action
            endcase
        end else begin
            control_data <= 5'b00000; // No action if not enabled
        end
    end
endmodule
