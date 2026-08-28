// ============================================================
// 檔名: key_decode.v   【狀態：學生已自行完成，邏輯正確，僅整理格式並補充註解】
// 功能: 依「掃描線 sel」與「讀回的行 column」判斷目前按下數字鍵盤上的哪一個鍵，
//       輸出對應的 scan_code(4bit BCD) 及 press(是否有鍵被按下)
// 註記: 原始上傳檔案結尾留了一段用 /* ... */ 註解掉的舊版程式碼(草稿)，
//       內容與正式版本重複、容易造成混淆，這裡已整段移除，只保留正式可用版本。
// ============================================================

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
                    // 按鍵 '1'：scan_code 改為 4'b0001 (顯示 1)
                    3'b011: begin scan_code = 4'b0001; press = 1'b1; end
                    // 按鍵 '2'：scan_code 改為 4'b0010 (顯示 2)
                    3'b101: begin scan_code = 4'b0010; press = 1'b1; end
                    // 按鍵 '3'：scan_code 改為 4'b0011 (顯示 3)
                    3'b110: begin scan_code = 4'b0011; press = 1'b1; end
                    // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                    default: begin scan_code = 4'b1111; press = 1'b0; end
                endcase
            3'b001:
                // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                case(column)
                    // 按鍵 '4'：scan_code 改為 4'b0100 (顯示 4)
                    3'b011: begin scan_code = 4'b0100; press = 1'b1; end
                    // 按鍵 '5'：scan_code 改為 4'b0101 (顯示 5)
                    3'b101: begin scan_code = 4'b0101; press = 1'b1; end
                    // 按鍵 '6'：scan_code 改為 4'b0110 (顯示 6)
                    3'b110: begin scan_code = 4'b0110; press = 1'b1; end
                    // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                    default: begin scan_code = 4'b1111; press = 1'b0; end
                endcase
            3'b010:
                // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                case(column)
                    // 按鍵 '7'：scan_code 改為 4'b0111 (顯示 7)
                    3'b011: begin scan_code = 4'b0111; press = 1'b1; end
                    // 按鍵 '8'：scan_code 改為 4'b1000 (顯示 8)
                    3'b101: begin scan_code = 4'b1000; press = 1'b1; end
                    // 按鍵 '9'：scan_code 改為 4'b1001 (顯示 9)
                    3'b110: begin scan_code = 4'b1001; press = 1'b1; end
                    // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                    default: begin scan_code = 4'b1111; press = 1'b0; end
                endcase
            3'b011:
                // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                case(column)
                    // 按鍵 '0'：scan_code 改為 4'b0000 (顯示 0)
                    3'b101: begin scan_code = 4'b0000; press = 1'b1; end
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
