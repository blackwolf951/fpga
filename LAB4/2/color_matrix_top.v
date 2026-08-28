module color_matrix_top(clk, rst, sel, row, column_green, column_red); // 拿掉 .v，整理參數順序
    input clk, rst;
    input [1:0] sel;    // 選擇LDE亮紅燈OR綠燈 (pin AA15, AA14)
    output [7:0] row, column_green, column_red; // column_green/red 比照Lab1
    
    wire clk_shift, clk_scan;
    wire [6:0] idx, idx_cnt;
    wire [7:0] column_out;
    
    assign column_green = (sel == 2'b01 || sel == 2'b11) ? column_out : 8'b0;
    assign column_red   = (sel == 2'b10 || sel == 2'b11) ? column_out : 8'b0;
    
    // 將內部訊號 (wire) 連接到各個子模組 (Port Mapping)
    freq_div #(22) M1 (
        .clk_in(clk), 
        .reset(rst), 
        .clk_out(clk_shift)
    );
    
    freq_div #(12) M2 (
        .clk_in(clk), 
        .reset(rst), 
        .clk_out(clk_scan)
    );
    
    idx_gen M3 (
        .clk(clk_shift), 
        .rst(rst), 
        .idx(idx)
    ); 
    
    row_gen M4 (
        .clk(clk_scan), 
        .rst(rst), 
        .idx(idx), 
        .row(row), 
        .idx_cnt(idx_cnt)
    );
    
    rom_char M5 (
        .addr(idx_cnt), 
        .data(column_out)
    );
    
endmodule