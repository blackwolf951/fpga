// ============================================================================
// [教學註解] 檔案：key_seg7_6dig_top.v
// [教學註解] 模組：key_seg7_6dig_top
// [教學註解] 功能：六位鍵盤七段顯示頂層：整合鍵盤掃描、去彈跳、歷史緩衝與顯示。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module key_seg7_6dig_top (clk, rst, column, sel, seg7);
    // [教學註解] 輸入埠：clk=系統時脈；rst=系統重置。
    input clk, rst;           // pin W16,C16[cite: 10]
    // [教學註解] 輸入埠：column=矩陣鍵盤欄輸入。
    input [2:0] column;       // pin AA13, AB12, Y16[cite: 10]
    // [教學註解] 輸出埠：sel=掃描選擇訊號。
    output [2:0] sel;         // pin AB10, AB11, AA12[cite: 10]
    // [教學註解] 輸出埠：seg7=七段顯示輸出。
    output [6:0] seg7;        // pin AB7,AA7,AB6,AB5,AA9,Y9,AB8[cite: 10]
    
    // [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
    wire clk_sel;
    // [教學註解] 連接線(wire)：key_code=目前選中的按鍵碼。
    wire [3:0] key_code;
    
    // 串接除頻器
    // [教學註解] 實例化 freq_div（U_fd）：把此子模組接進目前階層，完成「時脈分頻器：利用二進位計數器的高位元，將輸入時脈降低為較慢的時脈供後級電路使用。」
    freq_div #(13) U_fd(
        .clk_in(clk), .reset(rst), .clk_out(clk_sel)
    );
    
    // 串接六位數鍵盤控制模組
    // [教學註解] 實例化 key_seg7_6dig（U_key6）：把此子模組接進目前階層，完成「六位七段顯示控制：把多組鍵碼依掃描時序輸出到七段顯示器。」
    key_seg7_6dig U_key6(
        .clk_sel(clk_sel), .rst(rst), .column(column), .sel(sel), .key_code(key_code)
    );
    
    // 串接七段顯示解碼器
    // [教學註解] 實例化 bcd_to_seg7（U_bcd）：把此子模組接進目前階層，完成「BCD 轉七段顯示解碼器：把 4-bit 數字代碼轉成 a~g 七個 LED 段的點亮組合。」
    bcd_to_seg7 U_bcd(
        .bcd_in(key_code), .seg7(seg7)
    );
endmodule