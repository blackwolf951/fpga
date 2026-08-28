module scroll (clk, reset, shift_red, shift_green);
    input clk, reset;
    output [7:0] shift_red, shift_green;
    wire [7:0] shift_red, shift_green;
    reg [8:0] pattern;

    // 移除多餘的串接大括號 {}，讓語法更簡潔
    assign shift_red   = pattern[8] ? 8'b00000000 : pattern[7:0];
    assign shift_green = pattern[8] ? pattern[7:0] : 8'b00000000;

    // 將 always 區塊獨立換行，提升可讀性
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pattern <= 9'b0_1110_0000; // 改用非阻塞賦值 (<=)
        end else begin
            case(pattern)
                9'b0_11100000: pattern <= 9'b0_01110000; // 改用非阻塞賦值 (<=)
                9'b0_01110000: pattern <= 9'b0_00111000;
                9'b0_00111000: pattern <= 9'b0_00011100;
                9'b0_00011100: pattern <= 9'b0_00001110;
                9'b0_00001110: pattern <= 9'b0_00000111;
                9'b0_00000111: pattern <= 9'b1_00001110;
                9'b1_00001110: pattern <= 9'b1_00011100;
                9'b1_00011100: pattern <= 9'b1_00111000;
                9'b1_00111000: pattern <= 9'b1_01110000;
                9'b1_01110000: pattern <= 9'b1_11100000;
                9'b1_11100000: pattern <= 9'b0_01110000;
                default: pattern <= 9'b0_11100000;
            endcase
        end
    end
endmodule