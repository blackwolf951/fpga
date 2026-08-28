// ============================================================
// 檔名: red_dot_top.v
// 功能: 整合「碰撞小紅點遊戲」與「Lab8 六位數七段顯示器歷史顯示」之頂層模組
// ============================================================
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

    wire        ck, press, press_vaild, coll;
    wire  [3:0] keycode, scancode, addr, key_code;
    wire  [2:0] idx;
    wire  [7:0] hor, ver;
    wire [23:0] display_code;

    // 地圖與碰撞狀態位址合成
    assign addr = { coll, idx };

    // ---- 1. 分頻器：由快速時脈 clk 產生遊戲邏輯用的慢速時脈 ck ----
    freq_div #(14) M6 (
        .clk_in(clk), 
        .reset(reset), 
        .clk_out(ck)
    );

    // ---- 2. 鍵盤掃描：count6 產生 sel 掃描線(0~5循環) ----
    count6 M4 (
        .clk(ck), 
        .rst(reset), 
        .sel(sel)
    );

    // ---- 3. 鍵盤解碼：依 sel、column 判斷按下哪個鍵 ----
    key_decode M1 (
        .sel(sel), 
        .column(column), 
        .press(press), 
        .scan_code(scancode)
    );

    // ---- 4. 按鍵去彈跳：轉成乾淨的單一有效脈波 press_vaild ----
    vaild M3 (
        .clk(ck), 
        .rst(reset), 
        .press(press), 
        .press_valid(press_vaild)
    );

    // ---- 5A. 遊戲用的 4-bit 鍵值鎖存 (給 move 模組控制方向) ----
    key_buf M2 (
        .clk(ck), 
        .rst(reset), 
        .press_valid(press_vaild), 
        .scan_code(scancode), 
        .keycode(keycode)
    );

    // ---- 5B. 七段顯示器用的 24-bit 歷史鍵值鎖存 (Lab 8 核心) ----
    key_buf6 U_buf6 (
        .clk(ck), 
        .rst(reset), 
        .press_valid(press_vaild), 
        .scan_code(scancode), 
        .display_code(display_code)
    );

    // ---- 6. 移動控制：依 keycode 產生方向信號並移動紅點位置 ----
    move M5 (
        .reset(reset), 
        .unable(coll), 
        .keycode(keycode), 
        .ver(ver), 
        .hor(hor), 
        .clk(ck)
    );

    // ---- 7. 8x8 掃描位址：用快速時脈 clk 讓 idx/row 快速輪轉避免畫面閃爍 ----
    idx M8 (
        .clk(ck), 
        .reset(reset), 
        .idx(idx), 
        .row(row)
    );

    // ---- 8. 地圖(牆)資料：依 {coll, idx} 找出目前這一列的牆壁圖案 ----
    map M7 (
        .addr(addr), 
        .data(green)
    );

    // ---- 9. 紅點合成：比對 ver/hor 與 row 算出紅點位置 ----
    mix M9 (
        .ver(ver), 
        .hor(hor), 
        .row(row), 
        .red(red)
    );

    // ---- 10. 碰撞偵測：紅點與牆壁重疊即觸發撞牆保護 ----
    collision M10 (
        .clk(clk), 
        .reset(reset), 
        .red(red), 
        .green(green), 
        .coll(coll)
    );

    // ---- 11A. 七段顯示器多工選擇器：依目前 sel 選擇對應位數的按鍵代碼 ----
    key_code_mux U_mux (
        .display_code(display_code), 
        .sel(sel), 
        .key_code(key_code)
    );

    // ---- 11B. 七段顯示解碼器：將當前選中的 key_code 轉換為 7 段顯示信號 ----
    bcd_to_seg7 U_bcd (
        .bcd_in(key_code), 
        .seg7(seg7)
    );

endmodule
