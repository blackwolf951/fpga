module scroll (clk, reset, shift_out);
input 	clk, reset;
output	[7:0]shift_out;
reg		[7:0]shift_out;
always@ (posedge clk or posedge reset)
begin
	if(reset)
		shift_out= 8'b1100_0000;
	else
		shift_out= {shift_out[0], shift_out[7:1]};
	end
endmodule
