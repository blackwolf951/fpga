module key_seg7_6dig_top (clk, rst, column, sel, seg7);
    input clk, rst;           // pin W16,C16[cite: 10]
    input [2:0] column;       // pin AA13, AB12, Y16[cite: 10]
    output [2:0] sel;         // pin AB10, AB11, AA12[cite: 10]
    output [6:0] seg7;        // pin AB7,AA7,AB6,AB5,AA9,Y9,AB8[cite: 10]
    
    wire clk_sel;
    wire [3:0] key_code;
    
    // 串接除頻器
    freq_div #(13) U_fd(
        .clk_in(clk), .reset(rst), .clk_out(clk_sel)
    );
    
    // 串接六位數鍵盤控制模組
    key_seg7_6dig U_key6(
        .clk_sel(clk_sel), .rst(rst), .column(column), .sel(sel), .key_code(key_code)
    );
    
    // 串接七段顯示解碼器
    bcd_to_seg7 U_bcd(
        .bcd_in(key_code), .seg7(seg7)
    );
endmodule