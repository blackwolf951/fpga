// ============================================================================
// [教學註解] 檔案：traffic.v
// [教學註解] 模組：traffic
// [教學註解] 功能：交通號誌核心整合：連接燈號控制器與兩組倒數計數器。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module traffic (clk_fst, clk_cnt_dn, rst, day_night, g1_cnt, g2_cnt, light_led, mode_out);
    // [教學註解] 輸入埠：clk_fst=快速掃描時脈；clk_cnt_dn=倒數計數時脈；rst=系統重置；day_night=日/夜模式選擇。
    input       clk_fst, clk_cnt_dn, rst, day_night;
    // [教學註解] 輸出埠：light_led=紅黃綠燈 LED 控制。
    output[5:0] light_led;
    // [教學註解] 輸出埠：g1_cnt=第一方向倒數值。
    output[7:0] g1_cnt;
    // [教學註解] 輸出埠：g2_cnt=第二方向倒數值。
    output[7:0] g2_cnt;
    // [教學註解] 輸出埠：mode_out=輸出的交通號誌狀態。
    output[2:0] mode_out; // ★ 新增這一個輸出

    // [教學註解] 連接線(wire)：g1_en=第一方向計數致能；g2_en=第二方向計數致能。
    wire        g1_en, g2_en;

    // 將 ryg_ctl 的 mode_out 接出來
    // [教學註解] 實例化 ryg_ctl（M0）：把此子模組接進目前階層，完成「紅黃綠燈控制器：依狀態與倒數值控制交通燈模式、致能與燈號輸出。」
    ryg_ctl M0(
        .clk_fst(clk_fst), .clk_cnt_dn(clk_cnt_dn), .rst(rst), .day_night(day_night),
        .g1_cnt(g1_cnt), .g2_cnt(g2_cnt), .g1_en(g1_en), .g2_en(g2_en), 
        .light_led(light_led), .mode_out(mode_out) 
    );
    
    // [教學註解] 實例化 light_cnt_dn_29（M1）：把此子模組接進目前階層，完成「交通燈倒數計數器：以 BCD 方式由 29 往下倒數並配合致能控制。」
    light_cnt_dn_29 M1(.clk(clk_cnt_dn), .rst(rst), .enable(g1_en), .cnt(g1_cnt));
    // [教學註解] 實例化 light_cnt_dn_29（M2）：把此子模組接進目前階層，完成「交通燈倒數計數器：以 BCD 方式由 29 往下倒數並配合致能控制。」
    light_cnt_dn_29 M2(.clk(clk_cnt_dn), .rst(rst), .enable(g2_en), .cnt(g2_cnt));
endmodule