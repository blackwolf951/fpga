module key_led_top(clk, reset, column, sel, led, led_com);
    input clk, reset;
    input [2:0] column;
    output [2:0] sel;
    output [9:0] led;
    output led_com;
    
    assign led_com = 1'b1;
    wire clk_sel;
    wire [3:0] key_code;

    // 將頂層架構圖的三大區塊連接
    freq_div #(13) U_fd(
        .clk_in(clk), 
        .reset(reset), 
        .clk_out(clk_sel)
    );
    
    key_led U_kl(
        .clk_sel(clk_sel), 
        .reset(reset), 
        .column(column), 
        .sel(sel), 
        .key_code(key_code)
    );
    
    bcd_led U_bl(
        .key_code(key_code), 
        .led(led)
    );
endmodule