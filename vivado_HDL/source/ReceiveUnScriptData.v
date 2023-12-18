module ReceiveUnScriptData(
    input data_valid,
    input [7:0] data_receive,
    input uart_clk,
    input clk,
    output reg sig_front,
    output reg sig_hand,
    output reg sig_processing,
    output reg sig_machine,
    output reg [3:0] feedback_leds = 0,
    output reg led_mode = 0
);

parameter MAX = 15;

parameter FEEDBACK = 2'b01;


always @(posedge uart_clk) begin

    if(data_valid) begin


        if(data_receive[1:0]== FEEDBACK) begin
        
            feedback_leds <= data_receive[5:2];
            {sig_machine,sig_processing,sig_hand,sig_front} <= data_receive[5:2];
            led_mode <= 1;
         
        end else begin

            feedback_leds <= 4'b0000;
            {sig_machine,sig_processing,sig_hand,sig_front} <= 4'b0000;
            led_mode <= 0;

        end
    
    end

end

endmodule                                                                      