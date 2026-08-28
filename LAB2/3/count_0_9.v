// ============================================================================
// [教學註解] 檔案：count_0_9.v
// [教學註解] 模組：count_0_9
// [教學註解] 功能：BCD 個位數計數器：0→9 循環計數，數到 9 時產生進位訊號。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module count_0_9(clk, reset, enable, count_out, carry);
// [教學註解] 輸入埠：clk=系統時脈；reset=系統重置；enable=致能控制。
input clk, reset, enable;
// [教學註解] 輸出埠：count_out=目前計數值。
output[3:0] count_out;
// [教學註解] 輸出埠：carry=進位訊號。
output carry;
// [教學註解] 程序賦值暫存型訊號(reg)：count_out=目前計數值。
reg[3:0] count_out;
// [教學註解] 連續指定(assign)搭配 ?: 條件運算子，描述純組合邏輯，不需要時脈。
assign carry = (count_out== 4'b1001) ? 1 : 0;
// [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
always@ (posedge clk or posedge reset)begin
	// [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
	if(reset)
		count_out= 4'b0;
	// [教學註解] enable 成立才執行主要動作；enable=0 時通常保持目前狀態。
	else if(enable == 1) begin
		if(count_out== 4'b1001)
			count_out = 4'b0000;		// 數到9，歸零
		else
			// [教學註解] 計數 +1：每次有效時脈事件讓目前數值增加一。
			count_out = count_out + 1'b1;	// 否則加1
	end
end
endmodule
