module jump(
    input en,
    input [7:0] i_num,
    input [1:0] func,
    input [2:0] i_sign,
    input rst,
    input clk,
    input [7:0] current_pc,
    input [7:0] feedback_sig,  // Current state in the kitchen
    output reg [7:0] next_pc , // Changed to reg since we're assigning it in an always block
output reg is_ready = 0// turns to 1 if finish and 
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


always @(*) begin
    if (rst) begin
    signal = 0;
    mode = 0;
    next_pc =0;
    is_ready =0;
end else
    if (en) begin
         case (func)
            if_mode: mode = 1'b1;
            ifn_mode: mode = 1'b0;
        endcase
         case (i_sign)
            player_ready: signal = feedback_sig[2];
            player_hasitem: signal = feedback_sig[3];
            target_ready: signal = feedback_sig[4];
            target_hasitem: signal = feedback_sig[5];
        endcase
        if (signal == mode) begin
             next_pc = current_pc + (i_num)+(i_num); 
        end
        //prevent stucking in this script
        if (next_pc == current_pc) begin
            next_pc = current_pc +2'd2;
        end
        is_ready = 1'b1;
    end
end
endmodule
