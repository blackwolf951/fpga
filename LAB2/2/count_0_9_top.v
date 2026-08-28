// ============================================================================
// [教學註解] 檔案：count_0_9_top.v
// [教學註解] 模組：count_0_9_top
// [教學註解] 功能：0~9 計數顯示頂層：整合計數器、分頻器與七段顯示解碼。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module count_0_9_top(clk, reset, enable, seg7_sel, seg7_out, dpt_out, carry, led_com);
// [教學註解] 輸入埠：clk=系統時脈；reset=系統重置；enable=致能控制。
input clk, reset, enable;	//pin W16,C16,AA15
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output[2:0] seg7_sel;	//pin AB10,AB11,AA12
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output[6:0] seg7_out;	// pin AB7,AA7,AB6,AB5,AA9,Y9,AB8
// [教學註解] 輸出埠：carry=進位訊號。
output dpt_out, carry, led_com;	//pinAA8,E2,N20
// [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
wire clk_work;
// [教學註解] 連接線(wire)：count_out=目前計數值。
wire[3:0] count_out;

// [教學註解] 實例化 freq_div（M1）：把此子模組接進目前階層，完成「時脈分頻器：利用二進位計數器的高位元，將輸入時脈降低為較慢的時脈供後級電路使用。」
freq_div  #(21) M1 (clk, reset, clk_work);
// [教學註解] 實例化 count_0_9（M2）：把此子模組接進目前階層，完成「BCD 個位數計數器：0→9 循環計數，數到 9 時產生進位訊號。」
count_0_9       M2 (clk_work, reset, enable, count_out, carry);
// [教學註解] 實例化 bcd_to_seg7（M3）：把此子模組接進目前階層，完成「BCD 轉七段顯示解碼器：把 4-bit 數字代碼轉成 a~g 七個 LED 段的點亮組合。」
bcd_to_seg7     M3 (count_out, seg7_out);
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign seg7_sel = 3'b101;
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign dpt_out  = 1'b0;	//七段顯示器右下角小點不亮
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign led_com  = 1'b1;	//上排LED亮燈
endmodule
