module count_0_9_top(clk, reset, enable, seg7_sel, seg7_out, dpt_out, carry, led_com);
input clk, reset, enable;	//pin W16,C16,AA15
output[2:0] seg7_sel;	//pin AB10,AB11,AA12
output[6:0] seg7_out;	// pin AB7,AA7,AB6,AB5,AA9,Y9,AB8
output dpt_out, carry, led_com;	//pinAA8,E2,N20
wire clk_work;
wire[3:0] count_out;

freq_div  #(21) M1 (clk, reset, clk_work);
count_0_9       M2 (clk_work, reset, enable, count_out, carry);
bcd_to_seg7     M3 (count_out, seg7_out);
assign seg7_sel = 3'b101;
assign dpt_out  = 1'b0;	//七段顯示器右下角小點不亮
assign led_com  = 1'b1;	//上排LED亮燈
endmodule
