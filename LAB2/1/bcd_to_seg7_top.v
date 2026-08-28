// ============================================================================
// [教學註解] 檔案：bcd_to_seg7_top.v
// [教學註解] 模組：bcd_to_seg7_top
// [教學註解] 功能：七段顯示器頂層模組：整合分頻/計數/BCD 解碼後驅動七段顯示器。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module bcd_to_seg7_top(bcd_in, seg7_sel, seg7_out, dpt_out);
// [教學註解] 輸入埠：bcd_in=4-bit BCD 輸入。
input [3:0] bcd_in;	// pin AA15,AA14,AB18,AA18
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output [2:0] seg7_sel;	//pin AB10,AB11,AA12
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output [6:0] seg7_out;
// pin AB7,AA7,AB6,AB5,AA9,Y9,AB8
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output dpt_out;	// pin AA8

// [教學註解] 實例化 bcd_to_seg7（M1）：把此子模組接進目前階層，完成「BCD 轉七段顯示解碼器：把 4-bit 數字代碼轉成 a~g 七個 LED 段的點亮組合。」
bcd_to_seg7 M1 (bcd_in, seg7_out);
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign seg7_sel = 3'b101;	// Use the rightmost segment
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign dpt_out  = 1'b0;
endmodule
