// ============================================================================
// [教學註解] 檔案：key_led_top.v
// [教學註解] 模組：key_led_top
// [教學註解] 功能：鍵盤 LED 實驗頂層：整合鍵盤掃描、解碼、緩衝與 LED 顯示。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module key_led_top(clk, reset, column, sel, led, led_com);
    // [教學註解] 輸入埠：clk=系統時脈；reset=系統重置。
    input clk, reset;
    // [教學註解] 輸入埠：column=矩陣鍵盤欄輸入。
    input [2:0] column;
    // [教學註解] 輸出埠：sel=掃描選擇訊號。
    output [2:0] sel;
    // [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
    output [9:0] led;
    // [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
    output led_com;
    
    // [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
    assign led_com = 1'b1;
    // [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
    wire clk_sel;
    // [教學註解] 連接線(wire)：key_code=目前選中的按鍵碼。
    wire [3:0] key_code;

    // 將頂層架構圖的三大區塊連接
    // [教學註解] 實例化 freq_div（U_fd）：把此子模組接進目前階層，完成「時脈分頻器：利用二進位計數器的高位元，將輸入時脈降低為較慢的時脈供後級電路使用。」
    freq_div #(13) U_fd(
        .clk_in(clk), 
        .reset(reset), 
        .clk_out(clk_sel)
    );
    
    // [教學註解] 實例化 key_led（U_kl）：把此子模組接進目前階層，完成「鍵盤 LED 控制模組：依按鍵狀態產生對應 LED 顯示。」
    key_led U_kl(
        .clk_sel(clk_sel), 
        .reset(reset), 
        .column(column), 
        .sel(sel), 
        .key_code(key_code)
    );
    
    // [教學註解] 實例化 bcd_led（U_bl）：把此子模組接進目前階層，完成「BCD/LED 顯示控制：將數字代碼轉為 LED 或七段顯示格式。」
    bcd_led U_bl(
        .key_code(key_code), 
        .led(led)
    );
endmodule