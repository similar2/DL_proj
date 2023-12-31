module game_state (input en,
                   input [1:0] func,
                   input clk,
                   output reg [7:0] game_state); // Output should be declared as reg since it's assigned inside an always block
    
    
    
    always @(posedge clk) begin
        if (en) begin
            case (func)
                game_start: game_state <= GAME_START;
                game_end: game_state <= GAME_STOP;
            endcase
        end
    end
    
endmodule
