module count6(clk, rst, sel);
    input clk, rst;
    output reg [2:0] sel;

    // 循序邏輯：產生 000 -> 001 -> 010 -> 011 -> 100 -> 101 的循環計數
    always @(posedge clk or posedge rst) begin
        if (rst) 
            sel <= 3'b000;
        else if (sel == 3'b101) 
            sel <= 3'b000;      // 掃描完第6列後歸零
        else 
            sel <= sel + 1'b1;  // 移至下一列
    end
endmodule