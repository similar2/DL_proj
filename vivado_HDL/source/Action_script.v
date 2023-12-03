module action(
    input en,
    input [7:0] i_num,
    input [1:0] func,
    input clk,
    input [7:0] feedbak_sig,//current state in the kitchen
    output [4:0] control_data //control when to do the movement i.e. get put etc
);
    // Define parameters
    parameter GET = 2'b00, PUT = 2'b01, INTERACT = 2'b10, THROW = 2'b11;
    parameter ENABLED = 1'b1, DISABLED = 1'b0;

wire move_ready = feedbak_sig[2]; //whether the chef is in front of the target machine
    // Logic for enabling wires based on func
    //when the chef is in front of the target machine, u can continue ur movement
    wire get_en = (en == ENABLED)&&(move_ready == ENABLED) && (func == GET);
    wire put_en = (en == ENABLED)&&(move_ready == ENABLED) && (func == PUT);
    wire interact_en = (en == ENABLED) &&(move_ready == ENABLED)&& (func == INTERACT);
    wire throw_en = (en == ENABLED) &&(move_ready == ENABLED)&& (func == THROW);
    //be 1 only when other 4 signals are 0 
    wire move_en =(en ==ENABLED)&&~(get_en|put_en|interact_en|throw_en);
//control when and whether to move traveler to the target machine(only when set target machine to i_num and move only once)
//therefore, this sig will be set to 0 when traveller has moved

assign control_data = {move_en,get_en, put_en, interact_en, throw_en};

endmodule