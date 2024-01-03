module ShowGenshin(input clk,
                   output reg [3:0] dn0 = 0,
                   output reg [3:0] dn1 = 0,
                   output reg [7:0] bcd0 = 0,
                   output reg [7:0] bcd1 = 0);
    
    
    
    reg [1:0] bcd_cnt = 0;
    
    always @(posedge clk) begin
        case(bcd_cnt)
            2'b00: begin
                dn0 <= BCD_FIRST;
                dn1 <= BCD_FIRST;
                bcd0 <= BCD_LETTER_G;
                bcd1 <= BCD_LETTER_H;
            end
            2'b01: begin
                dn0 <= BCD_SECOND;
                dn1 <= BCD_SECOND;
                bcd0 <= BCD_LETTER_E;
                bcd1 <= BCD_LETTER_I;
            end
            2'b10: begin
                dn0 <= BCD_THRID;
                dn1 <= BCD_THRID;
                bcd0 <= BCD_LETTER_N;
                bcd1 <= BCD_LETTER_N;
            end
            2'b11: begin
                dn0 <= BCD_FORTH;
                dn1 <= BCD_EMPTY;
                bcd0 <= BCD_LETTER_S;
            end
        endcase
        if (bcd_cnt < BCD_NUM) begin
            bcd_cnt <= bcd_cnt + 1;
            end else begin
            bcd_cnt <= 0;
        end
    end
endmodule
