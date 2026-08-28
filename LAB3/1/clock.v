module clock(clk, reset, enable, count5, count4, count3, count2, count1, count0, carry);
// 補上宣告
input clk, reset, enable;
output [3:0] count5, count4, count3, count2, count1, count0;
output carry;

wire carry0, carry1, carry2;

// 秒數：00~59，收到外部的 enable 就跳動，數滿產生 carry0[cite: 22]
count_00_59_bcd M_sec (clk, reset, enable, count1, count0, carry0);

// 分鐘：00~59，將秒數的 carry0 當作自己的 enable，數滿產生 carry1[cite: 22]
count_00_59_bcd M_min (clk, reset, carry0, count3, count2, carry1);

// 小時：00~23，將分鐘的 carry1 當作自己的 enable[cite: 22]
count_00_23_bcd M_hr  (clk, reset, carry1, count5, count4, carry2); 

assign carry = carry2; // 將天數進位傳出去[cite: 22]
endmodule





//module clock(clk, reset, enable, count5, count4, count3, count2, count1, count0, carry);
// ...前面宣告省略[cite: 9]

// 秒數：00~59，收到外部的 enable 就跳動，數滿產生 carry0
//count_00_59_bcd M_sec (clk, reset, enable, count1, count0, carry0);

// 分鐘：00~59，將秒數的 carry0 當作自己的 enable，數滿產生 carry1[cite: 9]
//count_00_59_bcd M_min (clk, reset, carry0, count3, count2, carry1);

// 小時：00~23，將分鐘的 carry1 當作自己的 enable[cite: 9]
//count_00_23_bcd M_hr  (clk, reset, carry1, count5, count4, carry2); 

//assign carry = carry2; // 如果你需要把天數進位傳出去，可以這樣寫
//endmodule