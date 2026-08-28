module scroll (clk, reset, shift_out);
    input     clk, reset;
    output    [7:0] shift_out;
    wire      [7:0] shift_out;
    reg       [8:0] pattern;

    // 將 pattern 的低 8 位元輸出
    assign    shift_out = pattern[7:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pattern <= 9'b0_1110_0000; // 改用非阻塞賦值 <=
        end else begin
            case(pattern)
                // 往右位移
                9'b0_11100000: pattern <= 9'b0_01110000; // 補上分號，並改用 <=
                9'b0_01110000: pattern <= 9'b0_00111000;
                9'b0_00111000: pattern <= 9'b0_00011100;
                9'b0_00011100: pattern <= 9'b0_00001110;
                9'b0_00001110: pattern <= 9'b0_00000111;
                
                // 碰到最右邊，改變方向位元（最高位設為 1）並往左位移
                9'b0_00000111: pattern <= 9'b1_00001110;
                
                // 往左位移
                9'b1_00001110: pattern <= 9'b1_00011100;
                9'b1_00011100: pattern <= 9'b1_00111000;
                9'b1_00111000: pattern <= 9'b1_01110000;
                9'b1_01110000: pattern <= 9'b1_11100000;
                
                // 碰到最左邊，改變方向位元（最高位設為 0）並往右位移
                9'b1_11100000: pattern <= 9'b0_01110000;
                
                default: pattern <= 9'b0_11100000;
            endcase
        end
    end
endmodule