module key_buf(clk, rst, press, scan_code, key_code);
    input clk, rst, press;
    input [3:0] scan_code;
    output [3:0] key_code;
    reg [3:0] key_code;

    always @(posedge clk or posedge rst) begin
        if(rst)
            key_code <= 4'b1111; // initial value
        else
            // 邏輯：如果有按鍵按下(press=1)，讀取 scan_code，否則保持原本的 key_code[cite: 1]
            key_code <= press ? scan_code : key_code; 
    end
endmodule