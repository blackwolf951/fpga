// ============================================================
// 檔名: red_dot_top.v
// 功能: 整合「碰撞小紅點遊戲」與「Lab8 六位數七段顯示器歷史顯示」之頂層模組
// ============================================================

// ============================================================================
// [教學註解] 檔案：red_dot_top.v
// [教學註解] 模組：red_dot_top
// [教學註解] 功能：LAB8 紅點遊戲頂層：整合鍵盤、移動、8×8 地圖、碰撞偵測與七段顯示。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module red_dot_top (
    input         clk,         // 原始快速時脈 (例如 W16)
    input         reset,       // 系統重置訊號
    input   [2:0] column,      // 鍵盤掃描行輸入 (AA13, AB12, Y16)
    output  [7:0] red,         // 8x8 紅燈輸出 (紅點)
    output  [7:0] green,       // 8x8 綠燈輸出 (牆壁地圖)
    output  [7:0] row,         // 8x8 列掃描輸出
    output  [2:0] sel,         // 鍵盤掃描控制線 (AB10, AB11, AA12)
    output  [6:0] seg7         // 七段顯示器輸出 (AB7, AA7, AB6, AB5, AA9, Y9, AB8)
);

    // [教學註解] 連接線(wire)：press=按鍵是否被偵測；coll=碰撞狀態。
    wire        ck, press, press_vaild, coll;
    // [教學註解] 連接線(wire)：keycode=鎖存後的按鍵碼；scancode=掃描解出的按鍵碼；addr=ROM/地圖查表位址；key_code=目前選中的按鍵碼。
    wire  [3:0] keycode, scancode, addr, key_code;
    // [教學註解] 連接線(wire)：idx=目前掃描列索引。
    wire  [2:0] idx;
    // [教學註解] 連接線(wire)：hor=紅點水平 one-hot 位置；ver=紅點垂直 one-hot 位置。
    wire  [7:0] hor, ver;
    // [教學註解] 連接線(wire)：display_code=多位按鍵歷史資料。
    wire [23:0] display_code;

    // 地圖與碰撞狀態位址合成
    // [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
    assign addr = { coll, idx };

    // ---- 1. 分頻器：由快速時脈 clk 產生遊戲邏輯用的慢速時脈 ck ----
    // [教學註解] 實例化 freq_div（M6）：把此子模組接進目前階層，完成「時脈分頻器：利用二進位計數器的高位元，將輸入時脈降低為較慢的時脈供後級電路使用。」
    freq_div #(14) M6 (
        .clk_in(clk), 
        .reset(reset), 
        .clk_out(ck)
    );

    // ---- 2. 鍵盤掃描：count6 產生 sel 掃描線(0~5循環) ----
    // [教學註解] 實例化 count6（M4）：把此子模組接進目前階層，完成「6 狀態掃描計數器：循環產生多位顯示器或鍵盤掃描的選擇訊號。」
    count6 M4 (
        .clk(ck), 
        .rst(reset), 
        .sel(sel)
    );

    // ---- 3. 鍵盤解碼：依 sel、column 判斷按下哪個鍵 ----
    // [教學註解] 實例化 key_decode（M1）：把此子模組接進目前階層，完成「矩陣鍵盤解碼器：根據掃描列 sel 與輸入 column 判斷按鍵並輸出鍵碼。」
    key_decode M1 (
        .sel(sel), 
        .column(column), 
        .press(press), 
        .scan_code(scancode)
    );

    // ---- 4. 按鍵去彈跳：轉成乾淨的單一有效脈波 press_vaild ----
    // [教學註解] 實例化 vaild（M3）：把此子模組接進目前階層，完成「按鍵有效訊號產生器：利用連續取樣/移位方式抑制彈跳並輸出有效按鍵脈波。」
    vaild M3 (
        .clk(ck), 
        .rst(reset), 
        .press(press), 
        .press_valid(press_vaild)
    );

    // ---- 5A. 遊戲用的 4-bit 鍵值鎖存 (給 move 模組控制方向) ----
    // [教學註解] 實例化 key_buf（M2）：把此子模組接進目前階層，完成「按鍵緩衝暫存器：只在有效按鍵事件發生時更新並保存鍵碼。」
    key_buf M2 (
        .clk(ck), 
        .rst(reset), 
        .press_valid(press_vaild), 
        .scan_code(scancode), 
        .keycode(keycode)
    );

    // ---- 5B. 七段顯示器用的 24-bit 歷史鍵值鎖存 (Lab 8 核心) ----
    // [教學註解] 實例化 key_buf6（U_buf6）：把此子模組接進目前階層，完成「六位按鍵歷史緩衝：把最新鍵碼移入，保存最近多次按鍵供六位七段顯示。」
    key_buf6 U_buf6 (
        .clk(ck), 
        .rst(reset), 
        .press_valid(press_vaild), 
        .scan_code(scancode), 
        .display_code(display_code)
    );

    // ---- 6. 移動控制：依 keycode 產生方向信號並移動紅點位置 ----
    // [教學註解] 實例化 move（M5）：把此子模組接進目前階層，完成「紅點移動控制：將鍵碼解成上下左右方向，驅動水平/垂直移位暫存器。」
    move M5 (
        .reset(reset), 
        .unable(coll), 
        .keycode(keycode), 
        .ver(ver), 
        .hor(hor), 
        .clk(ck)
    );

    // ---- 7. 8x8 掃描位址：用快速時脈 clk 讓 idx/row 快速輪轉避免畫面閃爍 ----
    // [教學註解] 實例化 idx（M8）：把此子模組接進目前階層，完成「8×8 LED 掃描索引器：循環產生 idx 與對應 row，使各列快速輪流顯示。」
    idx M8 (
        .clk(ck), 
        .reset(reset), 
        .idx(idx), 
        .row(row)
    );

    // ---- 8. 地圖(牆)資料：依 {coll, idx} 找出目前這一列的牆壁圖案 ----
    // [教學註解] 實例化 map（M7）：把此子模組接進目前階層，完成「遊戲地圖 ROM：依掃描列與碰撞狀態輸出該列牆壁資料。」
    map M7 (
        .addr(addr), 
        .data(green)
    );

    // ---- 9. 紅點合成：比對 ver/hor 與 row 算出紅點位置 ----
    // [教學註解] 實例化 mix（M9）：把此子模組接進目前階層，完成「紅點畫面合成器：將水平與垂直位置和目前掃描列比對，產生 red 點陣資料。」
    mix M9 (
        .ver(ver), 
        .hor(hor), 
        .row(row), 
        .red(red)
    );

    // ---- 10. 碰撞偵測：紅點與牆壁重疊即觸發撞牆保護 ----
    // [教學註解] 實例化 collision（M10）：把此子模組接進目前階層，完成「碰撞偵測器：檢查 red 與 green 是否有同一位元同時為 1，並鎖存碰撞狀態。」
    collision M10 (
        .clk(clk), 
        .reset(reset), 
        .red(red), 
        .green(green), 
        .coll(coll)
    );

    // ---- 11A. 七段顯示器多工選擇器：依目前 sel 選擇對應位數的按鍵代碼 ----
    // [教學註解] 實例化 key_code_mux（U_mux）：把此子模組接進目前階層，完成「按鍵碼多工器：依目前掃描位數，從多組歷史鍵碼中選出一組送往七段解碼器。」
    key_code_mux U_mux (
        .display_code(display_code), 
        .sel(sel), 
        .key_code(key_code)
    );

    // ---- 11B. 七段顯示解碼器：將當前選中的 key_code 轉換為 7 段顯示信號 ----
    // [教學註解] 實例化 bcd_to_seg7（U_bcd）：把此子模組接進目前階層，完成「BCD 轉七段顯示解碼器：把 4-bit 數字代碼轉成 a~g 七個 LED 段的點亮組合。」
    bcd_to_seg7 U_bcd (
        .bcd_in(key_code), 
        .seg7(seg7)
    );

endmodule
