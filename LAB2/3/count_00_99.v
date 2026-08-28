module count_00_99(clk, reset, enable, count1_out, count0_out, carry);
input	clk, reset, enable;
output[3:0] count1_out, count0_out;
output	carry;
wire	carry0, carry1;
assign	carry = carry1 & carry0;

count_0_9 C1(clk, reset, enable, count0_out, carry0);		// 個位數：每個clk週期依enable計數
count_0_9 C2(clk, reset, carry0, count1_out, carry1);		// 十位數：個位數進位(carry0)時才加1
endmodule
