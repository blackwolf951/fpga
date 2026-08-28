module key_led(clk_sel, reset, column, sel, key_code);
    input clk_sel, reset;
    input [2:0] column;
    output [2:0] sel;
    output [3:0] key_code;
    
    wire press;
    wire [3:0] scan_code;
    // key_code 已經宣告為 output，不需要再宣告 wire key_code，避免重複宣告。

    // 依序填入前面撰寫的模組名稱進行具現化[cite: 7]
    count4 U_count4(
        .clk(clk_sel), 
        .rst(reset), 
        .sel(sel)
    );
    
    key_decode U_decode(
        .sel(sel), 
        .column(column), 
        .press(press), 
        .scan_code(scan_code)
    );
    
    key_buf U_buf(
        .clk(clk_sel), 
        .rst(reset), 
        .press(press), 
        .scan_code(scan_code), 
        .key_code(key_code)
    );
endmodule
