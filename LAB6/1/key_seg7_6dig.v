module key_seg7_6dig(clk_sel, rst, column, sel, key_code);
    input clk_sel, rst;
    input [2:0] column;
    output [2:0] sel;
    output [3:0] key_code;
    
    wire press, press_valid;
    wire [3:0] scan_code;
    wire [23:0] display_code;
    
    // 實體化所有子模組
    count6 U_count(
        .clk(clk_sel), .rst(rst), .sel(sel)
    );
    
    key_decode U_decode(
        .sel(sel), .column(column), .press(press), .scan_code(scan_code)
    );
    
    debounce_ctl U_debounce(
        .clk(clk_sel), .rst(rst), .press(press), .press_valid(press_valid)
    );
    
    key_buf6 U_buf6(
        .clk(clk_sel), .rst(rst), .press_valid(press_valid), .scan_code(scan_code), .display_code(display_code)
    );
    
    key_code_mux U_mux(
        .display_code(display_code), .sel(sel), .key_code(key_code)
    );
endmodule