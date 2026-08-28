// ============================================================================
// [教學註解] 檔案：frame_gen.v
// [教學註解] 模組：frame_gen
// [教學註解] 功能：8×8 LED 畫面產生器：整合掃描索引、ROM 圖樣與顏色/閃爍控制。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module frame_gen(
    input clk,
    input rst,
    input tick_scan,

    input [3:0] frame_idx,
    input       color_sel,
    input       day_night,

    output reg [7:0] matrix_row,
    output reg [7:0] matrix_red_col,
    output reg [7:0] matrix_green_col
);

    // =========================================================
    // 8x8 LED Matrix
    //
    // 使用你「正常能跑動畫」版本的掃描方式
    //
    // Row:
    //   10000000
    //   01000000
    //   00100000
    //   00010000
    //   00001000
    //   00000100
    //   00000010
    //   00000001
    //
    // =========================================================

    // [教學註解] 程序賦值暫存型訊號(reg)：宣告此區塊中使用的訊號與位元寬度。
    reg [2:0] row_idx;

    // [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
    wire [7:0] green_data;
    // [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
    wire [7:0] red_data;


    // =========================================================
    // Row counter
    // =========================================================

    // [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
    always @(posedge clk or posedge rst) begin

        // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
        if (rst) begin

            row_idx <= 3'd0;

        end

        else if (tick_scan) begin

            row_idx <= row_idx + 3'd1;

        end

    end


    // =========================================================
    // ROM
    // =========================================================

    // [教學註解] 實例化 pedestrian_rom_green（U_GREEN）：把此子模組接進目前階層，完成「綠色行人圖示 ROM：依掃描列位址輸出 8×8 綠色圖樣資料。」
    pedestrian_rom_green U_GREEN (
        .frame(frame_idx),
        .row(row_idx),
        .data(green_data)
    );


    // [教學註解] 實例化 pedestrian_rom_red（U_RED）：把此子模組接進目前階層，完成「紅色行人圖示 ROM：依掃描列位址輸出 8×8 紅色圖樣資料。」
    pedestrian_rom_red U_RED (
        .row(row_idx),
        .data(red_data)
    );


    // =========================================================
    // Row output
    // ACTIVE HIGH
    // =========================================================

    // [教學註解] 組合邏輯 always @(*)：任何被讀取的輸入改變時都重新計算輸出。
    always @(*) begin

        matrix_row = 8'b0;

        // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
        case (row_idx)

            3'd0: matrix_row = 8'b1000_0000;
            3'd1: matrix_row = 8'b0100_0000;
            3'd2: matrix_row = 8'b0010_0000;
            3'd3: matrix_row = 8'b0001_0000;
            3'd4: matrix_row = 8'b0000_1000;
            3'd5: matrix_row = 8'b0000_0100;
            3'd6: matrix_row = 8'b0000_0010;
            3'd7: matrix_row = 8'b0000_0001;

            // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
            default:
                matrix_row = 8'b0;

        endcase

    end


    // =========================================================
    // Column output
    // =========================================================

    // [教學註解] 組合邏輯 always @(*)：任何被讀取的輸入改變時都重新計算輸出。
    always @(*) begin

        // 夜間：全部關閉
        if (!day_night) begin

            matrix_green_col = 8'h00;
            matrix_red_col   = 8'h00;

        end

        // 紅色小人
        else if (color_sel) begin

            matrix_green_col = 8'h00;
            matrix_red_col   = red_data;

        end

        // 綠色小人
        else begin

            matrix_green_col = green_data;
            matrix_red_col   = 8'h00;

        end

    end

endmodule