// ============================================================================
// [教學註解] 檔案：traffic_core.v
// [教學註解] 模組：traffic_core
// [教學註解] 功能：交通號誌狀態核心：以狀態機控制兩方向燈號與 BCD 倒數數值。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module traffic_core(
    input clk, input rst, input tick_1hz, input blink_1hz, input day_night,
    output reg [2:0] mode,
    output reg [7:0] g1_cnt,
    output reg [7:0] g2_cnt,
    output reg [5:0] light_led
);

    // [教學註解] function：建立可重複使用的組合邏輯函式，呼叫時直接回傳計算結果。
    function [7:0] dec_bcd;
        // [教學註解] 輸入埠：宣告此區塊中使用的訊號與位元寬度。
        input [7:0] value;
        begin
            if (value == 8'h00)
                dec_bcd = 8'h29;
            else if (value[3:0] == 4'd0)
                // [教學註解] 計數 -1：每次有效時脈事件讓目前數值減少一。
                dec_bcd = {value[7:4] - 1'b1, 4'd9};
            else
                // [教學註解] 計數 -1：每次有效時脈事件讓目前數值減少一。
                dec_bcd = value - 1'b1;
        end
    endfunction

    // [教學註解] 組合邏輯 always @(*)：任何被讀取的輸入改變時都重新計算輸出。
    always @(*) begin
        // [教學註解] 日/夜模式判斷：不同模式會選擇不同的交通燈控制策略。
        if (!day_night)
            // [教學註解] 串接運算 { } 重新排列位元，可用來實作移位或把多個欄位合併成一個匯流排。
            light_led = {1'b0, blink_1hz, 1'b0, 1'b0, blink_1hz, 1'b0};
        else begin
            // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
            case (mode)
                3'd0: light_led = 6'b001100;
                // [教學註解] 串接運算 { } 重新排列位元，可用來實作移位或把多個欄位合併成一個匯流排。
                3'd1: light_led = {2'b00, blink_1hz, 1'b1, 2'b00};
                3'd2: light_led = 6'b010100;
                3'd3: light_led = 6'b100001;
                // [教學註解] 串接運算 { } 重新排列位元，可用來實作移位或把多個欄位合併成一個匯流排。
                3'd4: light_led = {1'b1, 4'b0000, blink_1hz};
                3'd5: light_led = 6'b100010;
                // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                default: light_led = 6'b001100;
            endcase
        end
    end

    // [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
    always @(posedge clk or posedge rst) begin
        // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
        if (rst) begin
            mode <= 3'd0;
            g1_cnt <= 8'h00;
            g2_cnt <= 8'h00;
        end else if (tick_1hz) begin
            // [教學註解] 日/夜模式判斷：不同模式會選擇不同的交通燈控制策略。
            if (!day_night) begin
                mode <= 3'd0;
                g1_cnt <= 8'h00;
                g2_cnt <= 8'h00;
            end else begin
                // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                case (mode)
                    3'd0: begin
                        g2_cnt <= 8'h00;
                        if (g1_cnt == 8'h00) g1_cnt <= 8'h29;
                        else g1_cnt <= dec_bcd(g1_cnt);
                        if (g1_cnt == 8'h10) mode <= 3'd1; // 10->09
                    end

                    3'd1: begin
                        if (g1_cnt == 8'h00) g1_cnt <= 8'h29;
                        else g1_cnt <= dec_bcd(g1_cnt);
                        if (g1_cnt == 8'h05) mode <= 3'd2; // 05->04
                    end

                    3'd2: begin
                        if (g1_cnt != 8'h00) g1_cnt <= dec_bcd(g1_cnt);
                        if (g1_cnt == 8'h01) begin // 01->00
                            mode <= 3'd3;
                            g1_cnt <= 8'h00;
                            g2_cnt <= 8'h29;
                        end
                    end

                    3'd3: begin
                        g1_cnt <= 8'h00;
                        if (g2_cnt == 8'h00) g2_cnt <= 8'h29;
                        else g2_cnt <= dec_bcd(g2_cnt);
                        if (g2_cnt == 8'h10) mode <= 3'd4; // 10->09
                    end

                    3'd4: begin
                        if (g2_cnt == 8'h00) g2_cnt <= 8'h29;
                        else g2_cnt <= dec_bcd(g2_cnt);
                        if (g2_cnt == 8'h05) mode <= 3'd5; // 05->04
                    end

                    3'd5: begin
                        if (g2_cnt != 8'h00) g2_cnt <= dec_bcd(g2_cnt);
                        if (g2_cnt == 8'h01) begin // 01->00
                            mode <= 3'd0;
                            g2_cnt <= 8'h00;
                            g1_cnt <= 8'h29;
                        end
                    end

                    // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                    default: begin
                        mode <= 3'd0;
                        g1_cnt <= 8'h00;
                        g2_cnt <= 8'h00;
                    end
                endcase
            end
        end
    end
endmodule
