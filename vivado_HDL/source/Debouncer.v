module Debouncer(
    input clk,             // Clock input
    input btn_input,       // Bouncing button input
    output reg btn_output  // Debounced button output
);

// Parameter definition
parameter DEBOUNCE_TIME = 1000000;  // Set the debounce time threshold
reg [19:0] counter = 0;             // 20-bit counter for debounce timing

// Debounce logic
always @(posedge clk) begin
    if (btn_input == btn_output) begin
        // If button state is stable, reset the counter
        counter <= 0;
    end else begin
        // If button state changes, start counting
        if (counter < DEBOUNCE_TIME) begin
            // If the timer has not reached the threshold, continue counting
            counter <= counter + 1;
        end else begin
            // If the threshold is reached, update the button state
            btn_output <= btn_input;
            counter <= 0; // Reset the counter for the next debounce
        end
    end
end

endmodule
