// ============================================================================
// [教學註解] 檔案：pedestrian_rom_red.v
// [教學註解] 模組：pedestrian_rom_red
// [教學註解] 功能：紅色行人圖示 ROM：依掃描列位址輸出 8×8 紅色圖樣資料。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module pedestrian_rom_red(
    input [2:0] row,
    output reg [7:0] data
);
    // [教學註解] 組合邏輯 always @(*)：任何被讀取的輸入改變時都重新計算輸出。
    always @(*) begin
        // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
        case (row)
            3'd0: data = 8'h0A;
            3'd1: data = 8'h04;
            3'd2: data = 8'h04;
            3'd3: data = 8'h1F;
            3'd4: data = 8'h04;
            3'd5: data = 8'h0E;
            3'd6: data = 8'h0E;
            3'd7: data = 8'h0E;
            // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
            default: data = 8'h00;
        endcase
    end
endmodule
