module GameStateChange(
    input switch,
    output reg [7:0] data = 8'bxxxx_10_01;
);

parameter START = 2'b01 , STOP = 2'b10;

always @(switch) begin
    if(switch) begin
        data[3:2] = START;
    end else begin
        data[3:2] = STOP;
    end
end

endmodule