module freq_div(clk_in, reset, clk_out);
parameter exp = 20;   
input clk_in, reset;
output clk_out;
reg[exp-1:0] divider;
integer i;
assign clk_out= divider[exp-1];
always@ (posedge clk_in or posedge reset)	//正緣觸發
begin
if(reset)
for(i=0; i < exp; i=i+1)
divider[i] = 1'b0;
else
divider = divider+ 1'b1;
end
endmodule // <--- ADDED THIS LINE

/*4. 為什麼以前的 freq_div #(23) 不準？
以前是
assign clk_out = divider[22];
實際頻率
10,000,000
──────────────
2^23=1.1920929 Hz
週期1 / 1.192≈0.83886 秒
不是1秒。

因此你的時鐘一天會快很多。
如果用 freq_div #(24)？
10,000,000

────────────
2^24=0.596046Hz
週期1.6777 秒
又太慢。
因此
任何 2^N 都不可能得到剛好1秒。*/