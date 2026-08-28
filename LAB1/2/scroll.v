module scroll (
    input  wire clk,
    input  wire reset,
    output wire [7:0] shift_out
);

    reg [8:0] pattern;

    // 第 8 位元 (pattern[8]) 是方向旗标，实际输出只取低 8 位元
    assign shift_out = pattern[7:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pattern <= 9'b0_1100_0000;
        end else begin
            case(pattern)
                // 方向旗标为 0：向右位移
                9'b0_1100_0000: pattern <= 9'b0_0110_0000;  
                9'b0_0110_0000: pattern <= 9'b0_0011_0000;
                9'b0_0011_0000: pattern <= 9'b0_0001_1000;  
                9'b0_0001_1000: pattern <= 9'b0_0000_1100;
                9'b0_0000_1100: pattern <= 9'b0_0000_0110;  
                9'b0_0000_0110: pattern <= 9'b0_0000_0011;
                
                // 碰到右边界，方向旗标改为 1，并开始向左位移
                9'b0_0000_0011: pattern <= 9'b1_0000_0110;  
                
                // 方向旗标为 1：向左位移
                9'b1_0000_0110: pattern <= 9'b1_0000_1100;
                9'b1_0000_1100: pattern <= 9'b1_0001_1000;  
                9'b1_0001_1000: pattern <= 9'b1_0011_0000;
                9'b1_0011_0000: pattern <= 9'b1_0110_0000;  
                9'b1_0110_0000: pattern <= 9'b1_1100_0000;
                
                // 碰到左边界，方向旗标改为 0，并开始向右位移
                9'b1_1100_0000: pattern <= 9'b0_0110_0000;  
                
                default: pattern <= 9'b0_1100_0000;
            endcase
        end
    end

endmodule