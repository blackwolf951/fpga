module count_00_99_top(clk, reset, seg7_sel, enable, seg7_out, dpt_out, carry, led_com);
input		clk, reset, enable;	//pin W16,C16,AA15
output[2:0]	seg7_sel;	//pin AB10,AB11,AA12
output[6:0]	seg7_out;	// pin AB7,AA7,AB6,AB5,AA9,Y9,AB8
output	dpt_out, led_com, carry;
wire		clk_count, clk_sel;
wire[3:0]	count_out, count1, count0;
assign	dpt_out = 1'b0;
assign	led_com = 1'b1;
assign count_out = (seg7_sel == 3'b101 )? count0 : count1;	//MUX：個位/十位切換

freq_div #(21) M1 (clk, reset, clk_count);			// slow：計數用時脈
freq_div #(17) M2 (clk, reset, clk_sel);			// high：掃描切換用時脈
count_00_99    M3 (clk_count, reset, enable, count1, count0, carry);
bcd_to_seg7    M4 (count_out, seg7_out);
seg7_select #(2) M5 (clk_sel, reset, seg7_sel);
endmodule
