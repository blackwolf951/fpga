// ============================================================================
// [教學註解] 檔案：key_led.v
// [教學註解] 模組：key_led
// [教學註解] 功能：鍵盤 LED 控制模組：依按鍵狀態產生對應 LED 顯示。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module key_led(clk_sel, reset, column, sel, key_code);
    // [教學註解] 輸入埠：reset=系統重置。
    input clk_sel, reset;
    // [教學註解] 輸入埠：column=矩陣鍵盤欄輸入。
    input [2:0] column;
    // [教學註解] 輸出埠：sel=掃描選擇訊號。
    output [2:0] sel;
    // [教學註解] 輸出埠：key_code=目前選中的按鍵碼。
    output [3:0] key_code;
    
    // [教學註解] 連接線(wire)：press=按鍵是否被偵測。
    wire press;
    // [教學註解] 連接線(wire)：scan_code=掃描解出的按鍵碼。
    wire [3:0] scan_code;
    // key_code 已經宣告為 output，不需要再宣告 wire key_code，避免重複宣告。

    // 依序填入前面撰寫的模組名稱進行具現化[cite: 7]
    // [教學註解] 實例化 count4（U_count4）：把此子模組接進目前階層，完成「4-bit 計數器：依時脈與重置訊號產生循環計數值。」
    count4 U_count4(
        .clk(clk_sel), 
        .rst(reset), 
        .sel(sel)
    );
    
    // [教學註解] 實例化 key_decode（U_decode）：把此子模組接進目前階層，完成「矩陣鍵盤解碼器：根據掃描列 sel 與輸入 column 判斷按鍵並輸出鍵碼。」
    key_decode U_decode(
        .sel(sel), 
        .column(column), 
        .press(press), 
        .scan_code(scan_code)
    );
    
    // [教學註解] 實例化 key_buf（U_buf）：把此子模組接進目前階層，完成「按鍵緩衝暫存器：只在有效按鍵事件發生時更新並保存鍵碼。」
    key_buf U_buf(
        .clk(clk_sel), 
        .rst(reset), 
        .press(press), 
        .scan_code(scan_code), 
        .key_code(key_code)
    );
endmodule
