// ============================================================================
// [教學註解] 檔案：key_buf6.v
// [教學註解] 模組：key_buf6
// [教學註解] 功能：六位按鍵歷史緩衝：把最新鍵碼移入，保存最近多次按鍵供六位七段顯示。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module key_buf6(clk, rst, press_valid, scan_code, display_code);
    // [教學註解] 輸入埠：clk=系統時脈；rst=系統重置；press_valid=去彈跳後的有效按鍵脈波。
    input clk, rst, press_valid;
    // [教學註解] 輸入埠：scan_code=掃描解出的按鍵碼。
    input [3:0] scan_code;
    // [教學註解] 輸出埠：display_code=多位按鍵歷史資料。
    output [23:0] display_code;
    // [教學註解] 程序賦值暫存型訊號(reg)：display_code=多位按鍵歷史資料。
    reg [23:0] display_code;
    
    // [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
    always@(posedge clk or posedge rst) begin
        // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
        if(rst)
            display_code <= 24'hffffff; // initial value
        else
            // 當輸入新資料時，舊資料向左移動，最右側填入新的 scan_code
            display_code <= press_valid ? {display_code[19:0], scan_code} : display_code; 
    end
endmodule