// ============================================================================
// [教學註解] 檔案：blink_gen.v
// [教學註解] 模組：blink_gen
// [教學註解] 功能：閃爍訊號產生器：依時間節拍翻轉輸出，供黃燈/行人燈閃爍使用。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module blink_gen(
    input clk, input rst, input tick_1hz,
    output reg blink
);
    // [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
    always @(posedge clk or posedge rst) begin
        // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
        if (rst) blink <= 1'b0;
        else if (tick_1hz) blink <= ~blink;
    end
endmodule
