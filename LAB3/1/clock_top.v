module clock_top(clk, reset, seg7_sel, enable, seg7_out, dpt_out, carry, led_com);
input       clk, reset, enable;
output[2:0] seg7_sel;
output[6:0] seg7_out;
output      dpt_out, led_com, carry;

wire        clk_count, clk_sel;
// 補齊 6 個位數的 wire[cite: 9]
wire[3:0]   count_out, count5, count4, count3, count2, count1, count0;

assign      led_com = 1'b1;

// MUX：6 個位數切換[cite: 9]
assign count_out = (seg7_sel == 3'b101) ? count0 : 
                   (seg7_sel == 3'b100) ? count1 :
                   (seg7_sel == 3'b011) ? count2 : 
                   (seg7_sel == 3'b010) ? count3 : 
                   (seg7_sel == 3'b001) ? count4 : count5;

// 小數點控制：依據講義將 dpt 在 HH.MM.SS 的間隔亮起[cite: 9]
assign dpt_out = (seg7_sel == 3'b101) ? 1'b1 : 
                 (seg7_sel == 3'b100) ? 1'b0 :
                 (seg7_sel == 3'b011) ? 1'b1 : 
                 (seg7_sel == 3'b010) ? 1'b0 : 
                 (seg7_sel == 3'b001) ? 1'b1 : 1'b0;

//freq_div #(23) M1 (clk, reset, clk_count);			
//freq_div_1s改改用更符合真實世界一秒

freq_div_1s M1(
    .clk_in(clk),
    .reset(reset),
    .clk_out(clk_count)
);

freq_div #(15) M2 (clk, reset, clk_sel);  // 掃描用的頻率建議設為15左右避免閃爍

// 實例化 24 小時制時鐘[cite: 9]
clock          M3 (clk_count, reset, enable, count5, count4, count3, count2, count1, count0, carry);
bcd_to_seg7    M4 (count_out, seg7_out);
seg7_select #(6) M5 (clk_sel, reset, seg7_sel); // 參數改為6[cite: 20]
endmodule






//module clock_top.v(clk, reset, seg7_sel, enable, seg7_out, dpt_out, carry, led_com);
//input		clk, reset, enable;	//pin W16,C16,AA15
//output[2:0]	seg7_sel;	//pin AB10,AB11,AA12
//output[6:0]	seg7_out;	// pin AB7,AA7,AB6,AB5,AA9,Y9,AB8
//output	dpt_out, led_com, carry;
//wire		clk_count, clk_sel;
//wire[3:0]	count_out, count1, count0;
//assign	dpt_out = 1'b0;
//assign	led_com = 1'b1;
//assign count_out = (seg7_sel == 3'b101 )? count0 : count1;	//MUX：個位/十位切換

//freq_div #(21) M1 (clk, reset, clk_count);			// slow：計數用時脈
//freq_div #(17) M2 (clk, reset, clk_sel);			// high：掃描切換用時脈
//count_00_99    M3 (clk_count, reset, enable, count1, count0, carry);
//bcd_to_seg7    M4 (count_out, seg7_out);
//seg7_select #(2) M5 (clk_sel, reset, seg7_sel);

//endmodule
