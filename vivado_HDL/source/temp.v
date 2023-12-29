`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/28 14:24:36
// Design Name: 
// Module Name: mem_tb
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

`timescale 1ns / 1ps

module ScriptMem_tb;

    // Inputs
    reg clock;
    reg reset;
    reg [7:0] dataOut_bits;
    reg dataOut_valid;
    reg [7:0] pc;

    // Outputs
    wire script_mode;
    wire [15:0] script;
    wire [7:0] script_num;

    // Instantiate the Unit Under Test (UUT)
    mem_array uut (
        .clock(clock), 
        .reset(reset), 
        .dataOut_bits(dataOut_bits), 
        .dataOut_valid(dataOut_valid), 
        .pc(pc), 
        .script_mode(script_mode), 
        .script(script), 
        .script_num(script_num)
    );

    // Clock generation
    always #5 clock = ~clock;  // Generate a clock with a period of 10ns

    // Test procedure
    initial fork
        // Initialize Inputs
        clock = 0;
        reset = 0;
        dataOut_bits = 0;
        dataOut_valid = 0;
        pc = 0;

        // Reset the system
        #10;
        reset = 1;

        // Test Case 1: Write data to memory
        #15;
        dataOut_bits = 8'b0000_1010;//1 scripts
        dataOut_valid = 1;
        #25;
        dataOut_bits = 8'b0000_1101;
        #35
        dataOut_bits = 8'b0110_0000;

        #35;
        dataOut_valid = 0;

        // Test Case 2: Read data from memory
        #40;
        pc = 0;  // Set the program counter to read the next instruction

        // Complete the test
  #100
  $finish;
    join
      
endmodule

