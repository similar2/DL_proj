module jump(
    input en,
    input [7:0] i_num,
    input [1:0] func,
    input [2:0] i_sign,
    input clk,
    input [7:0] current_pc,
    input [7:0] feedback_sig,  // Current state in the kitchen
    output reg [7:0] next_pc  // Changed to reg since we're assigning it in an always block
);

// Operation modes and their format:
// 010(00) - jumpif [i_num] [signal]   - Jump [i_num] lines if corresponding signal is 1.
// 010(01) - jumpifn [i_num] [signal]  - Jump [i_num] lines if corresponding signal is 0.

// Signal mapping to i_sign:
// 0 - player_ready
// 1 - player_hasitem
// 2 - target_ready
// 3 - target_hasitem


reg signal, mode;

always @(posedge clk) begin
    if (en) begin
        case (func)
            if_mode: mode <= 1'b1;
            ifn_mode: mode <= 1'b0;
        endcase
    end
end

always @(posedge clk) begin
    if (en) begin
        case (i_sign)
            player_ready: signal <= feedback_sig[2];
            player_hasitem: signal <= feedback_sig[3];
            target_ready: signal <= feedback_sig[4];
            target_hasitem: signal <= feedback_sig[5];
        endcase
    end
end

always @(posedge clk) begin
    if (en) begin
        next_pc <= current_pc + (2'd2 * i_num) * (signal ^ mode);
    end else begin
        next_pc <= current_pc;  // Maintain current PC if not enabled
    end
end

endmodule
