// ============================================================================
// [教學註解] 檔案：key_buf.v
// [教學註解] 模組：key_buf
// [教學註解] 功能：按鍵緩衝暫存器：只在有效按鍵事件發生時更新並保存鍵碼。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module key_buf(clk, rst, press, scan_code, key_code);
    // [教學註解] 輸入埠：clk=系統時脈；rst=系統重置；press=按鍵是否被偵測。
    input clk, rst, press;
    // [教學註解] 輸入埠：scan_code=掃描解出的按鍵碼。
    input [3:0] scan_code;
    // [教學註解] 輸出埠：key_code=目前選中的按鍵碼。
    output [3:0] key_code;
    // [教學註解] 程序賦值暫存型訊號(reg)：key_code=目前選中的按鍵碼。
    reg [3:0] key_code;

    // [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
    always @(posedge clk or posedge rst) begin
        // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
        if(rst)
            key_code <= 4'b1111; // initial value
        else
            // 邏輯：如果有按鍵按下(press=1)，讀取 scan_code，否則保持原本的 key_code[cite: 1]
            key_code <= press ? scan_code : key_code; 
    end
endmodule