// ============================================================
// 檔名: key_seg7_6dig.v （已修正，但建議「不要」加入這次紅點迷宮的 Quartus 專案）
// 原本錯誤: 內部呼叫的模組叫 debounce_ctl，但你的專案裡實際的模組名稱是 vaild，
//           找不到 debounce_ctl 會讓整個 Quartus 專案編譯失敗
//          (連紅點的部分也一起編譯不出來，因為是同一個 project)。
// 說明: 你的 red_dot_top.v 其實已經把 key_buf6 / key_code_mux / bcd_to_seg7
//       直接掛在頂層裡了，這個檔案是重複的，正常情況下不需要再加進專案。
//       如果你要單獨測試七段顯示器功能才需要用到這個檔案，這裡先幫你把它修好。
// ============================================================

// ============================================================================
// [教學註解] 檔案：key_seg7_6dig.v
// [教學註解] 模組：key_seg7_6dig
// [教學註解] 功能：六位七段顯示控制：把多組鍵碼依掃描時序輸出到七段顯示器。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module key_seg7_6dig(clk_sel, rst, column, sel, key_code);
    // [教學註解] 輸入埠：rst=系統重置。
    input clk_sel, rst;
    // [教學註解] 輸入埠：column=矩陣鍵盤欄輸入。
    input [2:0] column;
    // [教學註解] 輸出埠：sel=掃描選擇訊號。
    output [2:0] sel;
    // [教學註解] 輸出埠：key_code=目前選中的按鍵碼。
    output [3:0] key_code;
    
    // [教學註解] 連接線(wire)：press=按鍵是否被偵測；press_valid=去彈跳後的有效按鍵脈波。
    wire press, press_valid;
    // [教學註解] 連接線(wire)：scan_code=掃描解出的按鍵碼。
    wire [3:0] scan_code;
    // [教學註解] 連接線(wire)：display_code=多位按鍵歷史資料。
    wire [23:0] display_code;
    
    // 實體化所有子模組
    // [教學註解] 實例化 count6（U_count）：把此子模組接進目前階層，完成「6 狀態掃描計數器：循環產生多位顯示器或鍵盤掃描的選擇訊號。」
    count6 U_count(
        .clk(clk_sel), .rst(rst), .sel(sel)
    );
    
    // [教學註解] 實例化 key_decode（U_decode）：把此子模組接進目前階層，完成「矩陣鍵盤解碼器：根據掃描列 sel 與輸入 column 判斷按鍵並輸出鍵碼。」
    key_decode U_decode(
        .sel(sel), .column(column), .press(press), .scan_code(scan_code)
    );
    
    // [教學註解] 實例化 vaild（U_debounce）：把此子模組接進目前階層，完成「按鍵有效訊號產生器：利用連續取樣/移位方式抑制彈跳並輸出有效按鍵脈波。」
    vaild U_debounce(
        .clk(clk_sel), .rst(rst), .press(press), .press_valid(press_valid)
    );
    
    // [教學註解] 實例化 key_buf6（U_buf6）：把此子模組接進目前階層，完成「六位按鍵歷史緩衝：把最新鍵碼移入，保存最近多次按鍵供六位七段顯示。」
    key_buf6 U_buf6(
        .clk(clk_sel), .rst(rst), .press_valid(press_valid), .scan_code(scan_code), .display_code(display_code)
    );
    
    // [教學註解] 實例化 key_code_mux（U_mux）：把此子模組接進目前階層，完成「按鍵碼多工器：依目前掃描位數，從多組歷史鍵碼中選出一組送往七段解碼器。」
    key_code_mux U_mux(
        .display_code(display_code), .sel(sel), .key_code(key_code)
    );
endmodule
