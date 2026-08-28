// ============================================================
// 檔名: key_seg7_6dig.v （已修正，但建議「不要」加入這次紅點迷宮的 Quartus 專案）
// 原本錯誤: 內部呼叫的模組叫 debounce_ctl，但你的專案裡實際的模組名稱是 vaild，
//           找不到 debounce_ctl 會讓整個 Quartus 專案編譯失敗
//          (連紅點的部分也一起編譯不出來，因為是同一個 project)。
// 說明: 你的 red_dot_top.v 其實已經把 key_buf6 / key_code_mux / bcd_to_seg7
//       直接掛在頂層裡了，這個檔案是重複的，正常情況下不需要再加進專案。
//       如果你要單獨測試七段顯示器功能才需要用到這個檔案，這裡先幫你把它修好。
// ============================================================
module key_seg7_6dig(clk_sel, rst, column, sel, key_code);
    input clk_sel, rst;
    input [2:0] column;
    output [2:0] sel;
    output [3:0] key_code;
    
    wire press, press_valid;
    wire [3:0] scan_code;
    wire [23:0] display_code;
    
    // 實體化所有子模組
    count6 U_count(
        .clk(clk_sel), .rst(rst), .sel(sel)
    );
    
    key_decode U_decode(
        .sel(sel), .column(column), .press(press), .scan_code(scan_code)
    );
    
    vaild U_debounce(
        .clk(clk_sel), .rst(rst), .press(press), .press_valid(press_valid)
    );
    
    key_buf6 U_buf6(
        .clk(clk_sel), .rst(rst), .press_valid(press_valid), .scan_code(scan_code), .display_code(display_code)
    );
    
    key_code_mux U_mux(
        .display_code(display_code), .sel(sel), .key_code(key_code)
    );
endmodule
