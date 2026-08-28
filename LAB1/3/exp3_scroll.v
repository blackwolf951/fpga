module scroll (clk, reset, shift_out);
input	clk, reset;
output	[7:0]shift_out;
wire	[7:0]shift_out;
reg		[8:0]pattern;
assign	shift_out = pattern[7:0];

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
			9'b1_11100000: pattern = 9'b0_11100000;	// 講義原稿誤植為 0_01110000，此處修正回起始狀態
			default:       pattern = 9'b0_11100000;
		endcase
end
endmodule
