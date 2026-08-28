module bcd_to_seg7_top(bcd_in, seg7_sel, seg7_out, dpt_out);
input [3:0] bcd_in;	// pin AA15,AA14,AB18,AA18
output [2:0] seg7_sel;	//pin AB10,AB11,AA12
output [6:0] seg7_out;
// pin AB7,AA7,AB6,AB5,AA9,Y9,AB8
output dpt_out;	// pin AA8

bcd_to_seg7 M1 (bcd_in, seg7_out);
assign seg7_sel = 3'b101;	// Use the rightmost segment
assign dpt_out  = 1'b0;
endmodule
