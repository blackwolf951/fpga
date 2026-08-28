// ============================================================================
// [教學註解] 檔案：ryg_ctl.v
// [教學註解] 模組：ryg_ctl
// [教學註解] 功能：紅黃綠燈控制器：依狀態與倒數值控制交通燈模式、致能與燈號輸出。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module ryg_ctl (
    clk_fst, clk_cnt_dn, rst, day_night, g1_cnt, g2_cnt, g1_en, g2_en, light_led, mode_out
);
    // [教學註解] 輸入埠：clk_fst=快速掃描時脈；clk_cnt_dn=倒數計數時脈；rst=系統重置；day_night=日/夜模式選擇。
    input        clk_fst, clk_cnt_dn, rst, day_night;
    // [教學註解] 輸入埠：g1_cnt=第一方向倒數值；g2_cnt=第二方向倒數值。
    input  [7:0] g1_cnt, g2_cnt;
    // [教學註解] 輸出埠：g1_en=第一方向計數致能；g2_en=第二方向計數致能。
    output       g1_en, g2_en;
    // [教學註解] 輸出埠：light_led=紅黃綠燈 LED 控制。
    output [5:0] light_led;   // {L1, L2, L3, L4, L5, L6}
    // [教學註解] 輸出埠：mode_out=輸出的交通號誌狀態。
    output [2:0] mode_out;

    // [教學註解] 程序賦值暫存型訊號(reg)：g1_en=第一方向計數致能；g2_en=第二方向計數致能。
    reg g1_en, g2_en;
    // [教學註解] 程序賦值暫存型訊號(reg)：light_led=紅黃綠燈 LED 控制。
    reg [5:0] light_led;
    // [教學註解] 程序賦值暫存型訊號(reg)：mode=交通號誌狀態。
    reg [2:0] mode;

    // [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
    assign mode_out = mode;

    // [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
    always @(posedge clk_fst or posedge rst) begin
        // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
        if (rst) begin
            light_led <= 6'b001_100;     // L3(G1)亮, L4(R2)亮
            mode      <= 3'b000;
            g1_en     <= 1'b0;
            g2_en     <= 1'b0;
        end
        else if (day_night == 1'b1) begin      
            // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
            case (mode)
                // Mode 0: 綠燈1亮 (L3)，紅燈2亮 (L4)
                3'd0: begin
                    light_led <= 6'b001_100; // {0, 0, 1, 1, 0, 0}
                    g1_en <= 1'b1;
                    g2_en <= 1'b0;
                    if (g1_cnt == 8'b0000_1001) mode <= mode + 3'b1;
                end
                
                // Mode 1: 綠燈1閃爍 (L3)，紅燈2亮 (L4)
                3'd1: begin
                    g1_en <= 1'b1;
                    g2_en <= 1'b0;
                    if (g1_cnt == 8'b0000_0100) mode <= mode + 3'b1;
                    // [教學註解] 串接運算 { } 重新排列位元，可用來實作移位或把多個欄位合併成一個匯流排。
                    else light_led <= {2'b00, clk_cnt_dn, 1'b1, 2'b00}; 
                end
                
                // Mode 2: 黃燈1亮 (L2)，紅燈2亮 (L4)
                3'd2: begin
                    light_led <= 6'b010_100; // {0, 1, 0, 1, 0, 0}
                    g1_en <= 1'b1;
                    g2_en <= 1'b0;
                    if (g1_cnt == 8'b0000_0000) begin
                        g1_en <= 1'b0;
                        mode  <= mode + 3'b1;
                    end
                end
                
                // Mode 3: 紅燈1亮 (L1)，綠燈2亮 (L6)
                3'd3: begin
                    light_led <= 6'b100_001; // {1, 0, 0, 0, 0, 1}
                    g1_en <= 1'b0;
                    g2_en <= 1'b1;
                    if (g2_cnt == 8'b0000_1001) mode <= mode + 3'b1;
                end
                
                // Mode 4: 紅燈1亮 (L1)，綠燈2閃爍 (L6)
                3'd4: begin
                    g1_en <= 1'b0;
                    g2_en <= 1'b1;
                    if (g2_cnt == 8'b0000_0100) mode <= mode + 3'b1;
                    // [教學註解] 串接運算 { } 重新排列位元，可用來實作移位或把多個欄位合併成一個匯流排。
                    else light_led <= {1'b1, 4'b0000, clk_cnt_dn}; 
                end
                
                // Mode 5: 紅燈1亮 (L1)，黃燈2亮 (L5)
                3'd5: begin
                    light_led <= 6'b100_010; // {1, 0, 0, 0, 1, 0}
                    g1_en <= 1'b0;
                    g2_en <= 1'b1;
                    if (g2_cnt == 8'b0000_0000) begin
                        g2_en <= 1'b0;
                        mode <= 3'b000;
                    end
                end
                
                // 預防錯誤機制
                // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                default: begin
                    light_led <= 6'b001_100;
                    g1_en <= 1'b1;
                    g2_en <= 1'b0;
                    mode <= 3'b000;
                end
            endcase
        end
        else begin // 夜晚模式: 黃燈1閃爍 (L2)、黃燈2閃爍 (L5)
            // [教學註解] 串接運算 { } 重新排列位元，可用來實作移位或把多個欄位合併成一個匯流排。
            light_led <= {1'b0, clk_cnt_dn, 2'b00, clk_cnt_dn, 1'b0};
            g1_en <= 1'b0;
            g2_en <= 1'b0;
            mode  <= 3'b000;
        end
    end
endmodule