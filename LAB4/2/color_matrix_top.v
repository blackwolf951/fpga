// ============================================================================
// [教學註解] 檔案：color_matrix_top.v
// [教學註解] 模組：color_matrix_top
// [教學註解] 功能：8×8 彩色 LED 點矩陣頂層：整合列掃描、索引與字型 ROM 資料。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module color_matrix_top(clk, rst, sel, row, column_green, column_red); // 拿掉 .v，整理參數順序
    // [教學註解] 輸入埠：clk=系統時脈；rst=系統重置。
    input clk, rst;
    // [教學註解] 輸入埠：sel=掃描選擇訊號。
    input [1:0] sel;    // 選擇LDE亮紅燈OR綠燈 (pin AA15, AA14)
    // [教學註解] 輸出埠：row=8×8 列掃描訊號。
    output [7:0] row, column_green, column_red; // column_green/red 比照Lab1
    
    // [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
    wire clk_shift, clk_scan;
    // [教學註解] 連接線(wire)：idx=目前掃描列索引。
    wire [6:0] idx, idx_cnt;
    // [教學註解] 連接線(wire)：宣告此區塊中使用的訊號與位元寬度。
    wire [7:0] column_out;
    
    // [教學註解] 連續指定(assign)搭配 ?: 條件運算子，描述純組合邏輯，不需要時脈。
    assign column_green = (sel == 2'b01 || sel == 2'b11) ? column_out : 8'b0;
    // [教學註解] 連續指定(assign)搭配 ?: 條件運算子，描述純組合邏輯，不需要時脈。
    assign column_red   = (sel == 2'b10 || sel == 2'b11) ? column_out : 8'b0;
    
    // 將內部訊號 (wire) 連接到各個子模組 (Port Mapping)
    // [教學註解] 實例化 freq_div（M1）：把此子模組接進目前階層，完成「時脈分頻器：利用二進位計數器的高位元，將輸入時脈降低為較慢的時脈供後級電路使用。」
    freq_div #(22) M1 (
        .clk_in(clk), 
        .reset(rst), 
        .clk_out(clk_shift)
    );
    
    // [教學註解] 實例化 freq_div（M2）：把此子模組接進目前階層，完成「時脈分頻器：利用二進位計數器的高位元，將輸入時脈降低為較慢的時脈供後級電路使用。」
    freq_div #(12) M2 (
        .clk_in(clk), 
        .reset(rst), 
        .clk_out(clk_scan)
    );
    
    // [教學註解] 實例化 idx_gen（M3）：把此子模組接進目前階層，完成「掃描索引產生器：循環產生目前要顯示的列/行索引。」
    idx_gen M3 (
        .clk(clk_shift), 
        .rst(rst), 
        .idx(idx)
    ); 
    
    // [教學註解] 實例化 row_gen（M4）：把此子模組接進目前階層，完成「LED 點矩陣列掃描產生器：把索引轉換成 one-hot/掃描列訊號。」
    row_gen M4 (
        .clk(clk_scan), 
        .rst(rst), 
        .idx(idx), 
        .row(row), 
        .idx_cnt(idx_cnt)
    );
    
    // [教學註解] 實例化 rom_char（M5）：把此子模組接進目前階層，完成「字型 ROM：依位址查表輸出 8-bit 點矩陣字型資料。」
    rom_char M5 (
        .addr(idx_cnt), 
        .data(column_out)
    );
    
endmodule