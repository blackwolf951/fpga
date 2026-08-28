// ============================================================================
// [教學註解] 檔案：key_code_mux.v
// [教學註解] 模組：key_code_mux
// [教學註解] 功能：按鍵碼多工器：依目前掃描位數，從多組歷史鍵碼中選出一組送往七段解碼器。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module key_code_mux(display_code, sel, key_code);
    // [教學註解] 輸入埠：display_code=多位按鍵歷史資料。
    input [23:0] display_code;
    // [教學註解] 輸入埠：sel=掃描選擇訊號。
    input [2:0] sel;
    // [教學註解] 輸出埠：key_code=目前選中的按鍵碼。
    output [3:0] key_code;
    
    // [教學註解] 連續指定(assign)搭配 ?: 條件運算子，描述純組合邏輯，不需要時脈。
    assign key_code = (sel == 3'b101) ? display_code[3:0] :
                      (sel == 3'b100) ? display_code[7:4] :
                      (sel == 3'b011) ? display_code[11:8] :
                      (sel == 3'b010) ? display_code[15:12] :
                      (sel == 3'b001) ? display_code[19:16] :
                      (sel == 3'b000) ? display_code[23:20] : 
                      4'b1111;
endmodule