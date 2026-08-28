// ============================================================================
// [教學註解] 檔案：pedestrian_controller.v
// [教學註解] 模組：pedestrian_controller
// [教學註解] 功能：行人號誌控制器：依交通狀態與時間條件產生行人燈顯示控制。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module pedestrian_controller(
    input clk, input rst, input tick_2hz,
    input day_night, input [2:0] mode,
    output reg [3:0] frame_idx,
    output reg color_sel
);

    // [教學註解] 程序賦值暫存型訊號(reg)：宣告此區塊中使用的訊號與位元寬度。
    reg [1:0] frame_phase;

    // [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
    always @(posedge clk or posedge rst) begin
        // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
        if (rst) frame_phase <= 2'd0;
        else if (tick_2hz) begin
            // [教學註解] 日/夜模式判斷：不同模式會選擇不同的交通燈控制策略。
            if (day_night && (mode == 3'd0 || mode == 3'd1))
                // [教學註解] 計數 +1：每次有效時脈事件讓目前數值增加一。
                frame_phase <= frame_phase + 1'b1;
            else
                frame_phase <= 2'd0;
        end
    end

    // [教學註解] 組合邏輯 always @(*)：任何被讀取的輸入改變時都重新計算輸出。
    always @(*) begin
        // [教學註解] 日/夜模式判斷：不同模式會選擇不同的交通燈控制策略。
        if (!day_night) begin
            color_sel = 1'b0;
            frame_idx = 4'd0;
        end else begin
            // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
            case (mode)
                3'd0: begin
                    color_sel = 1'b0;
                    // [教學註解] 串接運算 { } 重新排列位元，可用來實作移位或把多個欄位合併成一個匯流排。
                    frame_idx = {2'b00, frame_phase};       // 0~3
                end
                3'd1: begin
                    color_sel = 1'b0;
                    frame_idx = 4'd4 + {2'b00, frame_phase}; // 4~7
                end
                // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                default: begin
                    color_sel = 1'b1;
                    frame_idx = 4'd0;
                end
            endcase
        end
    end
endmodule
