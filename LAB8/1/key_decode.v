// ============================================================
// 檔名: key_decode.v   【狀態：學生已自行完成，邏輯正確，僅整理格式並補充註解】
// 功能: 依「掃描線 sel」與「讀回的行 column」判斷目前按下數字鍵盤上的哪一個鍵，
//       輸出對應的 scan_code(4bit BCD) 及 press(是否有鍵被按下)
// 註記: 原始上傳檔案結尾留了一段用 /* ... */ 註解掉的舊版程式碼(草稿)，
//       內容與正式版本重複、容易造成混淆，這裡已整段移除，只保留正式可用版本。
// ============================================================
module key_decode(sel, column, press, scan_code);
    input [2:0] sel;
    input [2:0] column;
    output press;
    output [3:0] scan_code;

    reg [3:0] scan_code;
    reg press;

    always @(sel or column) begin
        case(sel)
            3'b000:
                case(column)
                    // 按鍵 '1'：scan_code 改為 4'b0001 (顯示 1)
                    3'b011: begin scan_code = 4'b0001; press = 1'b1; end
                    // 按鍵 '2'：scan_code 改為 4'b0010 (顯示 2)
                    3'b101: begin scan_code = 4'b0010; press = 1'b1; end
                    // 按鍵 '3'：scan_code 改為 4'b0011 (顯示 3)
                    3'b110: begin scan_code = 4'b0011; press = 1'b1; end
                    default: begin scan_code = 4'b1111; press = 1'b0; end
                endcase
            3'b001:
                case(column)
                    // 按鍵 '4'：scan_code 改為 4'b0100 (顯示 4)
                    3'b011: begin scan_code = 4'b0100; press = 1'b1; end
                    // 按鍵 '5'：scan_code 改為 4'b0101 (顯示 5)
                    3'b101: begin scan_code = 4'b0101; press = 1'b1; end
                    // 按鍵 '6'：scan_code 改為 4'b0110 (顯示 6)
                    3'b110: begin scan_code = 4'b0110; press = 1'b1; end
                    default: begin scan_code = 4'b1111; press = 1'b0; end
                endcase
            3'b010:
                case(column)
                    // 按鍵 '7'：scan_code 改為 4'b0111 (顯示 7)
                    3'b011: begin scan_code = 4'b0111; press = 1'b1; end
                    // 按鍵 '8'：scan_code 改為 4'b1000 (顯示 8)
                    3'b101: begin scan_code = 4'b1000; press = 1'b1; end
                    // 按鍵 '9'：scan_code 改為 4'b1001 (顯示 9)
                    3'b110: begin scan_code = 4'b1001; press = 1'b1; end
                    default: begin scan_code = 4'b1111; press = 1'b0; end
                endcase
            3'b011:
                case(column)
                    // 按鍵 '0'：scan_code 改為 4'b0000 (顯示 0)
                    3'b101: begin scan_code = 4'b0000; press = 1'b1; end
                    default: begin scan_code = 4'b1111; press = 1'b0; end
                endcase
            default: begin
                scan_code = 4'b1111; press = 1'b0;
            end
        endcase
    end
endmodule
