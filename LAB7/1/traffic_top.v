module traffic_top(clk, rst, day_night, light_led, led_com, seg7_out, seg7_sel);
    input       clk;
    input       rst;
    input       day_night;
    output[11:0] light_led;   // 擴展為 12 顆燈 (L1 ~ L12)
    output      led_com;
    output[2:0] seg7_sel;
    output[6:0] seg7_out;

    wire        clk_cnt_dn, clk_fst, clk_sel;
    wire [7:0]  g1_cnt, g2_cnt;
    wire [3:0]  count_out;
    
    // 擷取出來的狀態機模式 (0~5)
    wire [2:0]  current_mode;
    
    // 原始紅綠燈訊號暫存
    wire [5:0]  internal_light; 

    assign led_com = 1'b1;



	 // ====================================================================
    // 需求 2：七段顯示器客製化 (左邊 mode，右邊 countdown)
    // 依照實體板子排列：C1、C4 是最左邊(百位)，C3、C6 是最右邊(個位)
	  // 實驗板上的 C6~C1 對應的 sel 分別是 101~000
	  // active_cnt：把兩邊的倒數計時器疊加 (因為紅燈那方會是 0，疊加不影響)
    // ====================================================================
    // active_cnt：把兩邊的倒數計時器疊加
    // ====================================================================


    // ====================================================================
    // 七段顯示器客製化 (左邊倒數，右邊 mode)
    // ====================================================================
    wire [7:0] active_cnt = g1_cnt | g2_cnt;

    assign count_out = 
        // ------ 原本的右邊模塊 (現在改顯示在左邊) ------
        (seg7_sel == 3'b011) ? 4'd0 :                  // 百位: 顯示 0
        (seg7_sel == 3'b100) ? active_cnt[7:4] :       // 十位: 顯示倒數 十位數
        (seg7_sel == 3'b101) ? active_cnt[3:0] :       // 個位: 顯示倒數 個位數
        
        // ------ 原本的左邊模塊 (現在改顯示在右邊) ------
        (seg7_sel == 3'b000) ? 4'd0 :                  // 百位: 顯示 0
        (seg7_sel == 3'b001) ? 4'd0 :                  // 十位: 顯示 0
        (seg7_sel == 3'b010) ? {1'b0, current_mode} :  // 個位: 顯示 mode (0~5)
        4'd0;
		  


    //assign light_led = {internal_light[5:0], 6'b000000}; 
	 // 修正後：將訊號對應到低位元，讓 L1~L6 亮起
		assign light_led = {6'b000000, internal_light[5:0]};

    // 除頻器模組
    freq_div#(23) M0(.clk_in(clk), .reset(rst), .clk_out(clk_cnt_dn));
    freq_div#(21) M1(.clk_in(clk), .reset(rst), .clk_out(clk_fst));
    freq_div#(15) M2(.clk_in(clk), .reset(rst), .clk_out(clk_sel));

    // 整合主模組
    traffic M3(
        .clk_fst(clk_fst), .clk_cnt_dn(clk_cnt_dn), .rst(rst), .day_night(day_night),
        .g1_cnt(g1_cnt), .g2_cnt(g2_cnt), 
        .light_led(internal_light), // 先接到內部 wire
        .mode_out(current_mode)     // 取得 mode
    );

    // 七段顯示器解碼
    bcd_to_seg7 M4(.bcd_in(count_out), .seg7(seg7_out));

    // ★ 七段顯示器掃描控制：必須設為 6，讓 6 個數字都會被輪掃到
    seg7_select#(6) M5(.clk(clk_sel), .reset(rst), .seg7_sel(seg7_sel)); 

endmodule
