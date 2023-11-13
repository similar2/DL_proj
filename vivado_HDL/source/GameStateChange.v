module GameStateChange(
    input switch,
    output reg [7:0] data
);

always @(switch) begin
    if(switch) begin
        data[3:2] = 2'b01;
        data[1:0] = 2'b01;
    end else begin
        data[3:2] = 2'b10;
        data[1:0] = 2'b01;
    end
end

endmodule