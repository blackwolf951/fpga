// ============================================================================
// [教學註解] 檔案：seg7_select.v
// [教學註解] 模組：seg7_select
// [教學註解] 功能：七段顯示多工選擇器：依掃描選擇訊號，輪流選出要顯示的 BCD 位數。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module seg7_select(clk, reset, seg7_sel);
// [教學註解] 參數(parameter)：讓常數可以在實例化時調整，用來控制位寬、分頻比或狀態設定。
parameter	num_use = 6;	//設參數
// [教學註解] 輸入埠：clk=系統時脈；reset=系統重置。
input		clk, reset;
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output[2:0]	seg7_sel;
// [教學註解] 程序賦值暫存型訊號(reg)：宣告此區塊中使用的訊號與位元寬度。
reg	[2:0]	seg7_sel;
// [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
always@ (posedge clk or posedge reset) begin
	// [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
	if(reset == 1)
		seg7_sel = 3'b101;			// the rightmost one
	else
		if(seg7_sel == 6 - num_use)
			seg7_sel = 3'b101;
		else
			seg7_sel = seg7_sel - 3'b001;	// shift left
end
endmodule
