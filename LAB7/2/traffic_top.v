// ============================================================================
// [教學註解] 檔案：traffic_top.v
// [教學註解] 模組：traffic_top
// [教學註解] 功能：交通號誌頂層：整合時基、車道燈號、倒數顯示與相關控制模組。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module traffic_top #(
    // [教學註解] 參數(parameter)：讓常數可以在實例化時調整，用來控制位寬、分頻比或狀態設定。
    parameter CLK_FREQ_HZ = 8388608
)(
    input         clk,
    input         rst,
    input         day_night,
    output [11:0] light_led,
    output        led_com,
    output [6:0]  seg7_out,
    output [2:0]  seg7_sel,
    output [7:0]  matrix_row,
    output [7:0]  matrix_red_col,
    output [7:0]  matrix_green_col
);

    // [教學註解] 連接線(wire)：tick_1hz=每秒一次的時脈使能脈波。
    wire tick_1hz, tick_2hz, tick_256hz, tick_2048hz;
    // [教學註解] 連接線(wire)：blink_1hz=1 Hz 閃爍訊號。
    wire blink_1hz;
    // [教學註解] 連接線(wire)：mode=交通號誌狀態。
    wire [2:0] mode;
    // [教學註解] 連接線(wire)：g1_cnt=第一方向倒數值；g2_cnt=第二方向倒數值。
    wire [7:0] g1_cnt, g2_cnt;
    // [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
    wire [5:0] internal_light;
    // [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
    wire [3:0] ped_frame;
    // [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
    wire ped_color_red;
    // [教學註解] 程序賦值暫存型訊號(reg)：count_out=目前計數值。
    reg [3:0] count_out;

    // [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
    assign led_com   = 1'b1;
    // [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
    assign light_led = {6'b000000, internal_light};

    // [教學註解] 實例化 clock_enable（U_CLK）：把此子模組接進目前階層，完成「時脈使能產生器：以計數器產生週期性單脈波 tick，避免直接建立額外慢時脈。」
    clock_enable #(.CLK_FREQ_HZ(CLK_FREQ_HZ)) U_CLK (
        .clk(clk), .rst(rst),
        .tick_1hz(tick_1hz),
        .tick_2hz(tick_2hz),
        .tick_256hz(tick_256hz),
        .tick_2048hz(tick_2048hz)
    );

    // [教學註解] 實例化 blink_gen（U_BLINK）：把此子模組接進目前階層，完成「閃爍訊號產生器：依時間節拍翻轉輸出，供黃燈/行人燈閃爍使用。」
    blink_gen U_BLINK (
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz), .blink(blink_1hz)
    );

    // [教學註解] 實例化 traffic_core（U_TRAFFIC）：把此子模組接進目前階層，完成「交通號誌狀態核心：以狀態機控制兩方向燈號與 BCD 倒數數值。」
    traffic_core U_TRAFFIC (
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz),
        .blink_1hz(blink_1hz), .day_night(day_night),
        .mode(mode), .g1_cnt(g1_cnt), .g2_cnt(g2_cnt),
        .light_led(internal_light)
    );

    // [教學註解] 實例化 pedestrian_controller（U_PED）：把此子模組接進目前階層，完成「行人號誌控制器：依交通狀態與時間條件產生行人燈顯示控制。」
    pedestrian_controller U_PED (
        .clk(clk), .rst(rst), .tick_2hz(tick_2hz),
        .day_night(day_night), .mode(mode),
        .frame_idx(ped_frame), .color_sel(ped_color_red)
    );

    // [教學註解] 實例化 frame_gen（U_MATRIX）：把此子模組接進目前階層，完成「8×8 LED 畫面產生器：整合掃描索引、ROM 圖樣與顏色/閃爍控制。」
    frame_gen U_MATRIX (
        .clk(clk), .rst(rst), .tick_scan(tick_2048hz),
        .frame_idx(ped_frame), .color_sel(ped_color_red),
        .day_night(day_night),
        .matrix_row(matrix_row),
        .matrix_red_col(matrix_red_col),
        .matrix_green_col(matrix_green_col)
    );

    // [教學註解] 實例化 seg7_select（U_SEGSEL）：把此子模組接進目前階層，完成「七段顯示多工選擇器：依掃描選擇訊號，輪流選出要顯示的 BCD 位數。」
    seg7_select #(.num_use(6)) U_SEGSEL (
        .clk(clk), .reset(rst), .tick_scan(tick_256hz), .seg7_sel(seg7_sel)
    );

    // Mode 0/1: G1 countdown
    // Mode 3/4: G2 countdown
    // Mode 2/5 and night: 0
    // [教學註解] 組合邏輯 always @(*)：任何被讀取的輸入改變時都重新計算輸出。
    always @(*) begin
        count_out = 4'd0;
        // [教學註解] 日/夜模式判斷：不同模式會選擇不同的交通燈控制策略。
        if (day_night) begin
            // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
            case (mode)
                3'd0, 3'd1: begin
                    // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                    case (seg7_sel)
                        3'b101: count_out = g1_cnt[3:0];
                        3'b100: count_out = g1_cnt[7:4];
                        // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                        default: count_out = 4'd0;
                    endcase
                end
                3'd3, 3'd4: begin
                    // [教學註解] case 多路選擇：依目前輸入/狀態選擇對應的輸出資料。
                    case (seg7_sel)
                        3'b101: count_out = g2_cnt[3:0];
                        3'b100: count_out = g2_cnt[7:4];
                        // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                        default: count_out = 4'd0;
                    endcase
                end
                // [教學註解] default 提供未列舉情況的安全輸出，組合邏輯中可避免輸出沒有被指定而推導出 latch。
                default: count_out = 4'd0;
            endcase
        end
    end

    // [教學註解] 實例化 bcd_to_seg7（U_SEGDEC）：把此子模組接進目前階層，完成「BCD 轉七段顯示解碼器：把 4-bit 數字代碼轉成 a~g 七個 LED 段的點亮組合。」
    bcd_to_seg7 U_SEGDEC (.bcd_in(count_out), .seg7(seg7_out));

endmodule
