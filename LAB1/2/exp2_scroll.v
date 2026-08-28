module scroll (clk, reset, shift_out);
input	clk, reset;
output	[7:0]shift_out;
wire	[7:0]shift_out;
reg		[8:0]pattern;		// 多一位元(pattern[8])做方向旗標
assign	shift_out = pattern[7:0];

always@ (posedge clk or posedge reset)
begin
	if(reset)
		pattern = 9'b0_1100_0000;
	else
		case(pattern)
			9'b0_11000000: pattern = 9'b0_01100000;
			9'b0_01100000: pattern = 9'b0_00110000;
			9'b0_00110000: pattern = 9'b0_00011000;
			9'b0_00011000: pattern = 9'b0_00001100;
			9'b0_00001100: pattern = 9'b0_00000110;
			9'b0_00000110: pattern = 9'b0_00000011;
			9'b0_00000011: pattern = 9'b1_00000110;	// 撞到右邊界，方向旗標翻為1(開始左移)
			9'b1_00000110: pattern = 9'b1_00001100;
			9'b1_00001100: pattern = 9'b1_00011000;
			9'b1_00011000: pattern = 9'b1_00110000;
			9'b1_00110000: pattern = 9'b1_01100000;
			9'b1_01100000: pattern = 9'b1_11000000;
			9'b1_11000000: pattern = 9'b0_11000000;	// 撞到左邊界，方向旗標翻回0(開始右移)
			default:       pattern = 9'b0_11000000;
		endcase
end
endmodule
