module light_cnt_dn_29 (
    clk,
    rst,
    enable,
    cnt
);
input        clk;
input        rst;
input        enable;
output [7:0] cnt;
reg    [7:0] cnt;   // MSB[7:4] 十位數, LSB[3:0] 個位數

always @(posedge clk or posedge rst) begin
    if (rst)
        // 錯誤原始碼：
        // cnt = 8'b0;
        // 錯誤原因：
        // 時序電路 (clocked always block) 必須使用非阻塞賦值 <=，不可用 =
        cnt <= 8'b0;
    else if (enable) begin
        if (cnt == 8'b0) begin
            // 錯誤原始碼：
            // your code;   // 29
            // 說明：
            // 計數歸零代表一輪(29秒)倒數結束，重新載入 29 (BCD: 十位2, 個位9)
            cnt <= 8'b0010_1001;
        end
        else if (cnt[3:0] == 4'd0) begin
            // 錯誤原始碼：
            // your code;   // 20 -> 19
            // your code;   // 10 -> 09
            // 說明：
            // 個位數為0時要向十位數借位，個位數變成9
            cnt[7:4] <= cnt[7:4] - 1'b1;
            cnt[3:0] <= 4'd9;
        end
        else begin
            // 錯誤原始碼：
            // your code;   // 19 -> 18 -> ...
            // 說明：
            // 一般情況下，每個 clock 個位數直接減1
            cnt <= cnt - 1'b1;
        end
    end
    else
        // 錯誤原始碼：
        // cnt=8’b0;
        // 錯誤原因1：
        // 使用了全形單引號 ’（應為半形 '），會造成語法錯誤無法編譯
        // 錯誤原因2：
        // 時序電路建議一律使用非阻塞賦值 <=
        cnt <= 8'b0;
end
endmodule
