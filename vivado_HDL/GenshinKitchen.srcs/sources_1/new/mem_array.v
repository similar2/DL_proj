`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/28 14:23:41
// Design Name: 
// Module Name: mem_array
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

module mem_array(
    input        clock,             // connect to the same wire of UART module
                 reset,             // connect to the same wire of UART module
    input  [7:0] dataOut_bits,      // connect to the same wire of UART module
    input        dataOut_valid,     // connect to the same wire of UART module
    
    output       script_mode,       // If script_mode is 1, ignore the dataOut_bits from UART module
    input [7:0]  pc,                // program counter.
    output [15:0] script,           // instructions from pc.
    output [7:0] script_num
);

    reg [7:0] script_cnt = 0;
    reg [7:0] script_size = 0;
    reg [7:0] mem[127:0];  // Memory array to store script instructions

    assign script_mode = script_cnt < script_size;
    assign script_num = script_size;

    // Logic for reading and writing to the memory array
    always@(posedge clock or posedge reset) begin
        if(reset) begin
            script_cnt <= 0;
            script_size <= 0;
        end
        else if(dataOut_valid) begin
            if(script_mode) begin
                script_cnt <= script_cnt + 1;
                // Store data in memory when not in script_mode
                mem[script_cnt] <= {dataOut_bits};
            end 
            else if(dataOut_bits[1:0] == 2'b10) begin
                script_size <= dataOut_bits;
                script_cnt <= 0;
            end
        end
    end

    // Logic to output the script instruction
    assign script = (script_mode) ? 8'b0000_0000 : {mem[pc],mem[pc+1]};

endmodule
