module traffic (clk_fst, clk_cnt_dn, rst, day_night, g1_cnt, g2_cnt, light_led, mode_out);
    input       clk_fst, clk_cnt_dn, rst, day_night;
    output[5:0] light_led;
    output[7:0] g1_cnt;
    output[7:0] g2_cnt;
    output[2:0] mode_out; // ★ 新增這一個輸出

    wire        g1_en, g2_en;

    // 將 ryg_ctl 的 mode_out 接出來
    ryg_ctl M0(
        .clk_fst(clk_fst), .clk_cnt_dn(clk_cnt_dn), .rst(rst), .day_night(day_night),
        .g1_cnt(g1_cnt), .g2_cnt(g2_cnt), .g1_en(g1_en), .g2_en(g2_en), 
        .light_led(light_led), .mode_out(mode_out) 
    );
    
    light_cnt_dn_29 M1(.clk(clk_cnt_dn), .rst(rst), .enable(g1_en), .cnt(g1_cnt));
    light_cnt_dn_29 M2(.clk(clk_cnt_dn), .rst(rst), .enable(g2_en), .cnt(g2_cnt));
endmodule