module idx_gen(clk, rst, idx);
    input clk, rst;
    output [6:0] idx;
    reg [6:0] idx;
    
    always @(posedge clk or posedge rst) begin
        if (rst)
            idx <= 7'd88; // 初始位址設在最底端 (準備顯示9)
        else if (idx == 7'd0) 
            idx <= 7'd88; // 捲動到 0 消失後，重置回 88 繼續循環
        else
            idx <= idx - 7'd1; // 【關鍵修改】每次減1，產生往下倒退捲動的效果
    end
endmodule