// ============================================================================
// [教學註解] 檔案：clock_top.v
// [教學註解] 模組：clock_top
// [教學註解] 功能：數位時鐘頂層：整合 1 秒節拍、時分秒計數與七段顯示器掃描。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module clock_top(clk, reset, seg7_sel, enable, seg7_out, dpt_out, carry, led_com);
// [教學註解] 輸入埠：clk=系統時脈；reset=系統重置；enable=致能控制。
input       clk, reset, enable;
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output[2:0] seg7_sel;
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output[6:0] seg7_out;
// [教學註解] 輸出埠：carry=進位訊號。
output      dpt_out, led_com, carry;

// [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
wire        clk_count, clk_sel;
// 補齊 6 個位數的 wire[cite: 9]
// [教學註解] 連接線(wire)：count_out=目前計數值。
wire[3:0]   count_out, count5, count4, count3, count2, count1, count0;

// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign      led_com = 1'b1;

// MUX：6 個位數切換[cite: 9]
// [教學註解] 連續指定(assign)搭配 ?: 條件運算子，描述純組合邏輯，不需要時脈。
assign count_out = (seg7_sel == 3'b101) ? count0 : 
                   (seg7_sel == 3'b100) ? count1 :
                   (seg7_sel == 3'b011) ? count2 : 
                   (seg7_sel == 3'b010) ? count3 : 
                   (seg7_sel == 3'b001) ? count4 : count5;

// 小數點控制：依據講義將 dpt 在 HH.MM.SS 的間隔亮起[cite: 9]
// [教學註解] 連續指定(assign)搭配 ?: 條件運算子，描述純組合邏輯，不需要時脈。
assign dpt_out = (seg7_sel == 3'b101) ? 1'b1 : 
                 (seg7_sel == 3'b100) ? 1'b0 :
                 (seg7_sel == 3'b011) ? 1'b1 : 
                 (seg7_sel == 3'b010) ? 1'b0 : 
                 (seg7_sel == 3'b001) ? 1'b1 : 1'b0;

//freq_div #(23) M1 (clk, reset, clk_count);			
//freq_div_1s改改用更符合真實世界一秒

// [教學註解] 實例化 freq_div_1s（M1）：把此子模組接進目前階層，完成「1 秒節拍產生器：依輸入時脈累計週期，產生約 1 Hz 的時間基準。」
freq_div_1s M1(
    .clk_in(clk),
    .reset(reset),
    .clk_out(clk_count)
);

// [教學註解] 實例化 freq_div（M2）：把此子模組接進目前階層，完成「時脈分頻器：利用二進位計數器的高位元，將輸入時脈降低為較慢的時脈供後級電路使用。」
freq_div #(15) M2 (clk, reset, clk_sel);  // 掃描用的頻率建議設為15左右避免閃爍

// 實例化 24 小時制時鐘[cite: 9]
// [教學註解] 實例化 clock（M3）：把此子模組接進目前階層，完成「數位時鐘核心：串接秒、分、時三組 BCD 計數器，形成 HH:MM:SS。」
clock          M3 (clk_count, reset, enable, count5, count4, count3, count2, count1, count0, carry);
// [教學註解] 實例化 bcd_to_seg7（M4）：把此子模組接進目前階層，完成「BCD 轉七段顯示解碼器：把 4-bit 數字代碼轉成 a~g 七個 LED 段的點亮組合。」
bcd_to_seg7    M4 (count_out, seg7_out);
// [教學註解] 實例化 seg7_select（M5）：把此子模組接進目前階層，完成「七段顯示多工選擇器：依掃描選擇訊號，輪流選出要顯示的 BCD 位數。」
seg7_select #(6) M5 (clk_sel, reset, seg7_sel); // 參數改為6[cite: 20]
endmodule






//module clock_top.v(clk, reset, seg7_sel, enable, seg7_out, dpt_out, carry, led_com);
//input		clk, reset, enable;	//pin W16,C16,AA15
//output[2:0]	seg7_sel;	//pin AB10,AB11,AA12
//output[6:0]	seg7_out;	// pin AB7,AA7,AB6,AB5,AA9,Y9,AB8
//output	dpt_out, led_com, carry;
//wire		clk_count, clk_sel;
//wire[3:0]	count_out, count1, count0;
//assign	dpt_out = 1'b0;
//assign	led_com = 1'b1;
//assign count_out = (seg7_sel == 3'b101 )? count0 : count1;	//MUX：個位/十位切換

//freq_div #(21) M1 (clk, reset, clk_count);			// slow：計數用時脈
//freq_div #(17) M2 (clk, reset, clk_sel);			// high：掃描切換用時脈
//count_00_99    M3 (clk_count, reset, enable, count1, count0, carry);
//bcd_to_seg7    M4 (count_out, seg7_out);
//seg7_select #(2) M5 (clk_sel, reset, seg7_sel);

//endmodule
