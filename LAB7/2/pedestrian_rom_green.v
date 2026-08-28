// ============================================================================
// [教學註解] 檔案：pedestrian_rom_green.v
// [教學註解] 模組：pedestrian_rom_green
// [教學註解] 功能：綠色行人圖示 ROM：依掃描列位址輸出 8×8 綠色圖樣資料。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module pedestrian_rom_green(
    input [3:0] frame, input [2:0] row,
    output reg [7:0] data
);
    // [教學註解] 組合邏輯 always @(*)：任何被讀取的輸入改變時都重新計算輸出。
    always @(*) begin
        // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
        case ({frame,row})
            7'd0 : data = 8'h0A;  7'd1 : data = 8'h04;
            7'd2 : data = 8'h04;  7'd3 : data = 8'h1F;
            7'd4 : data = 8'h04;  7'd5 : data = 8'h0E;
            7'd6 : data = 8'h0E;  7'd7 : data = 8'h0E;

            7'd8 : data = 8'h14;  7'd9 : data = 8'h08;
            7'd10: data = 8'h08;  7'd11: data = 8'h3E;
            7'd12: data = 8'h08;  7'd13: data = 8'h1C;
            7'd14: data = 8'h1C;  7'd15: data = 8'h1C;

            7'd16: data = 8'h28;  7'd17: data = 8'h10;
            7'd18: data = 8'h10;  7'd19: data = 8'h7C;
            7'd20: data = 8'h10;  7'd21: data = 8'h38;
            7'd22: data = 8'h38;  7'd23: data = 8'h38;

            7'd24: data = 8'h50;  7'd25: data = 8'h20;
            7'd26: data = 8'h20;  7'd27: data = 8'hF8;
            7'd28: data = 8'h20;  7'd29: data = 8'h70;
            7'd30: data = 8'h70;  7'd31: data = 8'h70;

            7'd32: data = 8'h14;  7'd33: data = 8'h08;
            7'd34: data = 8'h1C;  7'd35: data = 8'h2A;
            7'd36: data = 8'h08;  7'd37: data = 8'h1C;
            7'd38: data = 8'h1C;  7'd39: data = 8'h1C;

            7'd40: data = 8'h28;  7'd41: data = 8'h10;
            7'd42: data = 8'h38;  7'd43: data = 8'h54;
            7'd44: data = 8'h10;  7'd45: data = 8'h38;
            7'd46: data = 8'h38;  7'd47: data = 8'h38;

            7'd48: data = 8'h28;  7'd49: data = 8'h10;
            7'd50: data = 8'h10;  7'd51: data = 8'h7C;
            7'd52: data = 8'h10;  7'd53: data = 8'h38;
            7'd54: data = 8'h38;  7'd55: data = 8'h38;

            7'd56: data = 8'h50;  7'd57: data = 8'h20;
            7'd58: data = 8'h20;  7'd59: data = 8'hF8;
            7'd60: data = 8'h20;  7'd61: data = 8'h70;
            7'd62: data = 8'h70;  7'd63: data = 8'h70;

            // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
            default: data = 8'h00;
        endcase
    end
endmodule
