// ============================================================
// 檔名: freq_div.v   【狀態：學生已自行完成，邏輯正確，僅補充註解】
// 功能: 分頻電路，用一個 exp-bit 的計數器持續累加，
//       取最高位元(MSB)當作輸出時脈 clk_out，達到「除以 2^exp」的效果
// 用法: 頂層以 freq_div #(14) M6(...) 呼叫，代表把 parameter exp 覆寫成14，
//       產生一個給鍵盤掃描/去彈跳/紅點移動用的慢速時脈 ck。
// ============================================================
module freq_div(clk_in, reset, clk_out);
    parameter exp = 20;         // 預設除頻位元數，可在例化時用 #(數值) 覆寫
    input clk_in, reset;
    output clk_out;

    reg [exp-1:0] divider;

    assign clk_out = divider[exp-1];   // 取最高位元，頻率 = clk_in / 2^exp

    always @(posedge clk_in or posedge reset) begin
        if (reset)
            divider <= 0;               // 重置後從0開始計數
        else
            divider <= divider + 1'b1;  // 每個clk_in上升緣就加1
    end
endmodule
