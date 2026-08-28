// ============================================================================
// [教學註解] 檔案：count_00_99.v
// [教學註解] 模組：count_00_99
// [教學註解] 功能：兩位 BCD 計數器：利用個位進位帶動十位，形成 00~99 計數。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module count_00_99(clk, reset, enable, count1_out, count0_out, carry);
// [教學註解] 輸入埠：clk=系統時脈；reset=系統重置；enable=致能控制。
input	clk, reset, enable;
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output[3:0] count1_out, count0_out;
// [教學註解] 輸出埠：carry=進位訊號。
output	carry;
// [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
wire	carry0, carry1;
// [教學註解] 連續指定(assign)：用位元邏輯即時計算輸出；任一輸入改變，結果就跟著改變。
assign	carry = carry1 & carry0;

// [教學註解] 實例化 count_0_9（C1）：把此子模組接進目前階層，完成「BCD 個位數計數器：0→9 循環計數，數到 9 時產生進位訊號。」
count_0_9 C1(clk, reset, enable, count0_out, carry0);		// 個位數：每個clk週期依enable計數
// [教學註解] 實例化 count_0_9（C2）：把此子模組接進目前階層，完成「BCD 個位數計數器：0→9 循環計數，數到 9 時產生進位訊號。」
count_0_9 C2(clk, reset, carry0, count1_out, carry1);		// 十位數：個位數進位(carry0)時才加1
endmodule
