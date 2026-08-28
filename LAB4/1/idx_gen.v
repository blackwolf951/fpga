module idx_gen(clk, rst, idx);
    input clk, rst;
    output [6:0] idx;
    reg [6:0] idx;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            idx <= 7'd0;
        else if (idx == 7'd88) // 改為 88，否則碰到 80 (數字9的開頭) 就會直接重置
            idx <= 7'd0;
        else
            idx <= idx + 7'd8; // 每次跳躍 8 個位址 (一個完整字元)
    end
endmodule