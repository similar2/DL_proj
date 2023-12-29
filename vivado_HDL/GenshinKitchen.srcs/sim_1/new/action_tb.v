`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/29 13:23:45
// Design Name: 
// Module Name: action_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module action_testbench;

    // Inputs
    reg rst;
    reg en;
    reg [7:0] i_num;
    reg [1:0] func;
    reg clk;
    reg move_ready;

    // Outputs
    wire [7:0] target_machine;
    wire [7:0] control_data;
    wire is_ready;
// op(func)	Format	Description
// 001(00)	get [i_num]	Move to the machine with ID [inum], then get an item.
// 001(01)	put [i_num]	Move to the machine with ID [inum], then put an item.
// 001(10)	interact [i_num]	Move to the machine with ID [inum], then interact it.
// 001(11)	throw [i_num]	No need to move, throw item to machine with ID [inum].
    // Instantiate the Unit Under Test (UUT)
    action uut (
        .rst(rst), 
        .en(en), 
        .i_num(i_num), 
        .func(func), 
        .clk(clk), 
        .move_ready(move_ready), 
        .target_machine(target_machine), 
        .control_data(control_data),
        .is_ready(is_ready)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Clock with 20ns period
    end

    // Test stimulus
    initial begin
        // Initialize Inputs
        rst = 1;
        en = 0;
        i_num = 0;
        func = 0;
        move_ready = 0;

        // Wait for the global reset
        #20;
        rst = 0;
    end
initial fork
    #30 begin//get 5
        en = 1;
      i_num = 8'd5;
      func=2'b00;

    end
    #60 begin
      move_ready = 1;
    end
    #110
    rst = 1;
    #111
    rst =0;
    #120 begin
    move_ready = 0;
      func = 2'b01;
    end
    #125 i_num = 8'd9;
    #200 move_ready = 1;
#500
$finish;
join
    // Optional: Displaying changes in the outputs
    initial begin
        $monitor("Time = %t, target_machine = %h, control_data = %h", $time, target_machine, control_data);
    end

endmodule
