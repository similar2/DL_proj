module WaitDebug(
    input en,
    input [7:0] i_num,
    input [1:0] func,
    input [2:0] i_sign,
    input millisecond_clk,
    input clk,  // ordinary uart_clk
    input [7:0] feedback_sig,  // Current state in the kitchen
    output is_ready  // when finish waiting is_ready turns 1 or this remains 0
);

// op(func) Format Description
// 011(00) wait [i_num] Wait about [i_num]*100 ms.
// 011(01) waituntil [signal] Wait till corresponding signal is 1.

// The i_sign sig remains the same as jump_script
// To implement the goal of wait and waituntil we need to specify the clk signal 
// In this module we use millisecond_clk, namely, whose period is 1ms

reg mode, signal;
reg [10:0] time_counter = 0;  // Initialized to 0
reg [10:0] wait_time = 0;  // Initialized to 0

always @(posedge clk ) begin
   if (en) begin
        case(func) 
            waituntil_mode: begin 
                mode <= 1'b1;
                wait_time <= i_num * 8'd100;
            end 
            wait_mode: mode <= 1'b0;
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

always @(posedge millisecond_clk) begin
    if (en) begin
        if (mode) begin  // just wait i_num*100 ms
            if (time_counter < wait_time) begin
                time_counter <= time_counter + 1;
            end
        end 
    end
end

assign is_ready = mode * (time_counter == wait_time) + (~mode) * signal;

endmodule