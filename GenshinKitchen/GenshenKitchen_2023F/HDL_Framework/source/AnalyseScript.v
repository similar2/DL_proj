`timescale 1ns/1ps

module AnalyseScript(
    input [15:0] script,
    input [7:0] pc,
    input script_mode,
    input output_ready,
    output reg [7:0] output_data
);

wire [7:0] i_num;
wire [2:0] i_sign;
wire [1:0] fun;
wire [2:0] op_code;

assign i_num = {script[15],script[14],script[13],script[12],script[11],script[10],script[9],script[8]};
assign i_sign = {script[7],script[6],script[5]};
assign fun = {script[4],script[3]};
assign op_code = {script[2],script[1],script[0]};

always@(*)
begin
    if(script_mode==0) // start to analyse script
    begin
        case(op_code)
            3'b001: // Action
            begin
                case(fun)
                    2'b00:
                    2'b01:
                    2'b10:
                    2'b11:
                    default:
                endcase
            end
            3'b010: // Jump
            begin
                case(fun)
                    2'b00:
                    2'b01:
                endcase
            end
            3'b011: // Wait
            begin
                case(fun)
                    2'b00:
                    2'b01:
                endcase
            end
            3'b100: // Game State
            begin
                case(fun)
                    2'b00:
                    2'b01:
                endcase
            end  
            default:
        endcase
    end
end

endmodule