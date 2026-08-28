module scroll (clk, reset, shift_red, shift_green, direction);
input	clk, reset;
output	[7:0]shift_red, shift_green;
output	direction;
wire	[7:0]shift_red, shift_green;
reg		[8:0]pattern;

assign shift_red   = pattern[8] ? 8'b0000_0000 : pattern[7:0];
assign shift_green = pattern[8] ? pattern[7:0] : 8'b0000_0000;
assign direction   = pattern[8];	// direction=0：右移(快)，direction=1：左移(慢)，供top選擇clk

always@ (posedge clk or posedge reset)
begin
	if(reset)
		pattern = 9'b0_1110_0000;
	else
		case(pattern)
			9'b0_11100000: pattern = 9'b0_01110000;
			9'b0_01110000: pattern = 9'b0_00111000;
			9'b0_00111000: pattern = 9'b0_00011100;
			9'b0_00011100: pattern = 9'b0_00001110;
			9'b0_00001110: pattern = 9'b0_00000111;
			9'b0_00000111: pattern = 9'b1_00001110;
			9'b1_00001110: pattern = 9'b1_00011100;
			9'b1_00011100: pattern = 9'b1_00111000;
			9'b1_00111000: pattern = 9'b1_01110000;
			9'b1_01110000: pattern = 9'b1_11100000;
			9'b1_11100000: pattern = 9'b0_11100000;
			default:       pattern = 9'b0_11100000;
		endcase
end
endmodule
