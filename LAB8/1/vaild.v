// ============================================================
// 檔名: vaild.v (依專案命名沿用 vaild 拼法，對應 lab6_debounce_ctl.v)
// 【狀態：學生已自行完成，邏輯正確，僅補充註解】
// 功能: 按鍵去彈跳(debounce) + 產生單一有效脈波
//       用一個 6-bit 移位暫存器把 press 訊號連續取樣6次，
//       只要 press 已經連續保持1超過5個clk(gg[5]變成1)，就不再視為新的按鍵事件，
//       避免「按住不放」時被誤判成連續多次按鍵
// 注意: 這裡的 clk 建議接「分頻後的慢速時脈 ck」，而不是快速原始時脈，
//       因為機械按鍵彈跳(bounce)通常會持續數毫秒，
//       如果clk太快，6個clk週期可能遠小於1毫秒，濾波效果會不夠。
// ============================================================
module vaild (clk, rst, press, press_valid);
    input press, clk, rst;
    output press_valid;
    reg [5:0] gg;

    // press_valid = 1，代表：目前正在按(press=1) 且 尚未被判定為「已持續按住」(gg[5]=0)
    assign press_valid = ~(gg[5] || (~press));

    always@(posedge clk or posedge rst) begin
        if(rst)
            gg <= 6'b0;                 // 重置移位暫存器
        else
            gg <= {gg[4:0], press};     // 每個clk把新的press值移入最低位元
    end
endmodule
