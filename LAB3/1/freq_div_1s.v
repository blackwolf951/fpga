module freq_div_1s(
    input  clk_in,
    input  reset,
    output reg clk_out
);

reg [23:0] count;

// 10MHz -> 1Hz
// 半週期 = 5,000,000 clocks
always @(posedge clk_in or posedge reset)
begin
    if(reset)
    begin
        count   <= 24'd0;
        clk_out <= 1'b0;
    end
    else
    begin
        if(count == 24'd4999999)
        begin
            count   <= 24'd0;
            clk_out <= ~clk_out;
        end
        else
        begin
            count <= count + 24'd1;
        end
    end
end

endmodule


/*你的板子
10MHz=10,000,000 次/秒
真正的1Hz
High：0.5 秒Low ：0.5 秒
因此0.5秒
10,000,000 × 0.5=5,000,000
所以
數5000000次
↓
翻轉clk_out
↓
再數5000000次
↓
再翻轉因此
5000000+5000000=10000000 clocks=1 second
*/