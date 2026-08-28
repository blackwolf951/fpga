// ============================================================================
// [教學註解] 檔案：clock.v
// [教學註解] 模組：clock
// [教學註解] 功能：數位時鐘核心：串接秒、分、時三組 BCD 計數器，形成 HH:MM:SS。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module clock(clk, reset, enable, count5, count4, count3, count2, count1, count0, carry);
// 補上宣告
// [教學註解] 輸入埠：clk=系統時脈；reset=系統重置；enable=致能控制。
input clk, reset, enable;
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output [3:0] count5, count4, count3, count2, count1, count0;
// [教學註解] 輸出埠：carry=進位訊號。
output carry;

// [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
wire carry0, carry1, carry2;

// 秒數：00~59，收到外部的 enable 就跳動，數滿產生 carry0[cite: 22]
// [教學註解] 實例化 count_00_59_bcd（M_sec）：把此子模組接進目前階層，完成「兩位 BCD 60 進位計數器：計數範圍 00~59，適合秒/分鐘。」
count_00_59_bcd M_sec (clk, reset, enable, count1, count0, carry0);

// 分鐘：00~59，將秒數的 carry0 當作自己的 enable，數滿產生 carry1[cite: 22]
// [教學註解] 實例化 count_00_59_bcd（M_min）：把此子模組接進目前階層，完成「兩位 BCD 60 進位計數器：計數範圍 00~59，適合秒/分鐘。」
count_00_59_bcd M_min (clk, reset, carry0, count3, count2, carry1);

// 小時：00~23，將分鐘的 carry1 當作自己的 enable[cite: 22]
// [教學註解] 實例化 count_00_23_bcd（M_hr）：把此子模組接進目前階層，完成「兩位 BCD 24 進位計數器：計數範圍 00~23，適合小時。」
count_00_23_bcd M_hr  (clk, reset, carry1, count5, count4, carry2); 

// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign carry = carry2; // 將天數進位傳出去[cite: 22]
endmodule





//module clock(clk, reset, enable, count5, count4, count3, count2, count1, count0, carry);
// ...前面宣告省略[cite: 9]

// 秒數：00~59，收到外部的 enable 就跳動，數滿產生 carry0
//count_00_59_bcd M_sec (clk, reset, enable, count1, count0, carry0);

// 分鐘：00~59，將秒數的 carry0 當作自己的 enable，數滿產生 carry1[cite: 9]
//count_00_59_bcd M_min (clk, reset, carry0, count3, count2, carry1);

// 小時：00~23，將分鐘的 carry1 當作自己的 enable[cite: 9]
//count_00_23_bcd M_hr  (clk, reset, carry1, count5, count4, carry2); 

//assign carry = carry2; // 如果你需要把天數進位傳出去，可以這樣寫
//endmodule