// ============================================================================
// [教學註解] 檔案：bonus_lab01_04_top.v
// [教學註解] 模組：lab01_04
// [教學註解] 功能：LAB1 加分題頂層模組：整合分頻與移位顯示功能。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module lab01_04 (clk, reset, shift_red, shift_green, ctl_bit);
// [教學註解] 輸入埠：clk=系統時脈。
input	clk;			// pin W16
// [教學註解] 輸入埠：reset=系統重置。
input	reset;			// pin C16
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output	[7:0]shift_red;
// pin D7, D6, A9, C9, A8, C8, C11, B11
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output	[7:0]shift_green;
// pin A10, B10, A13, A12, B12, D12, A15, A14
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output	ctl_bit;		// pin T22
// [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
wire	clk_slow, clk_fast, clk_work, direction;
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign	ctl_bit = 1'b1;
// [教學註解] 連續指定(assign)搭配 ?: 條件運算子，描述純組合邏輯，不需要時脈。
assign	clk_work = (direction) ? clk_slow : clk_fast;	// 左移(慢)用clk_slow，右移(快)用clk_fast

// [教學註解] 實例化 freq_div（M1）：把此子模組接進目前階層，完成「時脈分頻器：利用二進位計數器的高位元，將輸入時脈降低為較慢的時脈供後級電路使用。」
freq_div #(20) M1 (clk, reset, clk_slow);
// [教學註解] 實例化 freq_div（M2）：把此子模組接進目前階層，完成「時脈分頻器：利用二進位計數器的高位元，將輸入時脈降低為較慢的時脈供後級電路使用。」
freq_div #(18) M2 (clk, reset, clk_fast);
// [教學註解] 實例化 scroll（M3）：把此子模組接進目前階層，完成「循環移位暫存器：在時脈觸發時移動位元圖樣，用於 LED 跑馬燈/移位效果。」
scroll         M3 (clk_work, reset, shift_red, shift_green, direction);
endmodule
