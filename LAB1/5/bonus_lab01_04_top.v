module lab01_04 (clk, reset, shift_red, shift_green, ctl_bit);
input	clk;			// pin W16
input	reset;			// pin C16
output	[7:0]shift_red;
// pin D7, D6, A9, C9, A8, C8, C11, B11
output	[7:0]shift_green;
// pin A10, B10, A13, A12, B12, D12, A15, A14
output	ctl_bit;		// pin T22
wire	clk_slow, clk_fast, clk_work, direction;
assign	ctl_bit = 1'b1;
assign	clk_work = (direction) ? clk_slow : clk_fast;	// 左移(慢)用clk_slow，右移(快)用clk_fast

freq_div #(20) M1 (clk, reset, clk_slow);
freq_div #(18) M2 (clk, reset, clk_fast);
scroll         M3 (clk_work, reset, shift_red, shift_green, direction);
endmodule
