// ============================================================================
// [教學註解] 檔案：freq_div_1s.v
// [教學註解] 模組：freq_div_1s
// [教學註解] 功能：1 秒節拍產生器：依輸入時脈累計週期，產生約 1 Hz 的時間基準。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module freq_div_1s(
    input  clk_in,
    input  reset,
    output reg clk_out
);

// [教學註解] 程序賦值暫存型訊號(reg)：count=目前計數值。
reg [23:0] count;

// 10MHz -> 1Hz
// 半週期 = 5,000,000 clocks
// [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
always @(posedge clk_in or posedge reset)
begin
    // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
    if(reset)
    begin
        count   <= 24'd0;
        clk_out <= 1'b0;
    end
    else
    begin
        if(count == 24'd4999999)
        begin
            count   <= 24'd0;
            clk_out <= ~clk_out;
        end
        else
        begin
            count <= count + 24'd1;
        end
    end
end

endmodule


/*你的板子
10MHz=10,000,000 次/秒
真正的1Hz
High：0.5 秒Low ：0.5 秒
因此0.5秒
10,000,000 × 0.5=5,000,000
所以
數5000000次
↓
翻轉clk_out
↓
再數5000000次
↓
再翻轉因此
5000000+5000000=10000000 clocks=1 second
*/