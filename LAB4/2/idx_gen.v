module idx_gen(clk, rst, idx);
    input clk, rst;
    output [6:0] idx;
    reg [6:0] idx;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            idx <= 7'd0;
        else if (idx >= 7'd88) // 讓數字9完整往上捲動消失後再歸零
            idx <= 7'd0;
        else
            idx <= idx + 7'd1; // 【關鍵修改】每次只加1，產生往上捲動的效果
    end
endmodule