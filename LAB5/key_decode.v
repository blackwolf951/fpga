// ============================================================================
// [教學註解] 檔案：key_decode.v
// [教學註解] 模組：key_decode
// [教學註解] 功能：矩陣鍵盤解碼器：根據掃描列 sel 與輸入 column 判斷按鍵並輸出鍵碼。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module key_decode(sel, column, press, scan_code);
    // [教學註解] 輸入埠：sel=掃描選擇訊號。
    input [2:0] sel;
    // [教學註解] 輸入埠：column=矩陣鍵盤欄輸入。
    input [2:0] column;
    // [教學註解] 輸出埠：press=按鍵是否被偵測。
    output press;
    // [教學註解] 輸出埠：scan_code=掃描解出的按鍵碼。
    output [3:0] scan_code;
    
    // [教學註解] 程序賦值暫存型訊號(reg)：scan_code=掃描解出的按鍵碼。
    reg [3:0] scan_code;
    // [教學註解] 程序賦值暫存型訊號(reg)：press=按鍵是否被偵測。
    reg press;

    // [教學註解] 組合邏輯 always：敏感度表中的訊號改變時重新執行此區塊。
    always @(sel or column) begin
        // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
        case(sel)
            3'b000:
                // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                case(column)
                    // 原本 011 是 1，若要往旁邊移，改對應實際按下的 column 狀態
                    3'b011: begin scan_code = 4'b0000; press = 1'b1; end // 依實際情況微調
                    3'b101: begin scan_code = 4'b0001; press = 1'b1; end // 按 1 顯示 1
                    3'b110: begin scan_code = 4'b0010; press = 1'b1; end // 按 2 顯示 2
                    // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                    default: begin scan_code = 4'b1111; press = 1'b0; end
                endcase
            3'b001:
                // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                case(column)
                    3'b011: begin scan_code = 4'b0011; press = 1'b1; end 
                    3'b101: begin scan_code = 4'b0100; press = 1'b1; end 
                    3'b110: begin scan_code = 4'b0101; press = 1'b1; end 
                    // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                    default: begin scan_code = 4'b1111; press = 1'b0; end 
                endcase
            3'b010:
                // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                case(column)
                    3'b011: begin scan_code = 4'b0110; press = 1'b1; end 
                    3'b101: begin scan_code = 4'b0111; press = 1'b1; end 
                    3'b110: begin scan_code = 4'b1000; press = 1'b1; end 
                    // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                    default: begin scan_code = 4'b1111; press = 1'b0; end 
                endcase
            3'b011:
                // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                case(column)
                    3'b101: begin scan_code = 4'b1001; press = 1'b1; end 
                    // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                    default: begin scan_code = 4'b1111; press = 1'b0; end 
                endcase
            // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
            default: begin 
                scan_code = 4'b1111; press = 1'b0; 
            end
        endcase
    end
endmodule