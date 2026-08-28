module seg7_select(clk, reset, seg7_sel);
parameter	num_use = 6;	//設參數
input		clk, reset;
output[2:0]	seg7_sel;
reg	[2:0]	seg7_sel;
always@ (posedge clk or posedge reset) begin
	if(reset == 1)
		seg7_sel = 3'b101;			// the rightmost one
	else
		if(seg7_sel == 6 - num_use)
			seg7_sel = 3'b101;
		else
			seg7_sel = seg7_sel - 3'b001;	// shift left
end
endmodule
