module key_buf6(clk, rst, press_valid, scan_code, display_code);
    input clk, rst, press_valid;
    input [3:0] scan_code;
    output [23:0] display_code;
    reg [23:0] display_code;
    
    always@(posedge clk or posedge rst) begin
        if(rst)
            display_code <= 24'hffffff; // initial value
        else
            // 當輸入新資料時，舊資料向左移動，最右側填入新的 scan_code
            display_code <= press_valid ? {display_code[19:0], scan_code} : display_code; 
    end
endmodule