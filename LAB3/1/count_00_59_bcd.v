module count_00_59_bcd(clk, reset, enable, count1, count0, carry);
input clk, reset, enable;
output [3:0] count1, count0;
reg[3:0] count1, count0;
output carry;


wire carry = (count1 == 4'b0101 && count0 == 4'b1001 && enable == 1'b1) ? 1'b1 : 1'b0;
//因為沒有加上 enable 的條件，當分鐘數到 59 時，
//它的 carry 會在整個第 59 分鐘內長達 60 秒都保持開啟。
//這導致你的「小時」模組在這 60 秒內連續收到了 60 次進位訊號，60 除以 24 餘數剛好是 12，所以小時就會瞬間跳 12 步然後停住！

// 當數到 59 時 (十位數5=0101, 個位數9=1001)，發出進位訊號給下一個模組
//wire carry = (count1 == 4'b0101 && count0 == 4'b1001) ? 1 : 0; 

always@ (posedge clk or posedge reset)
begin
    if(reset) begin
        count1 = 4'b0000; // 00
        count0 = 4'b0000;
    end
    else if(enable == 1'b1) begin
        if (count1 == 4'b0101 && count0 == 4'b1001) begin
            // 數到 59，下一個 clock 歸零
            count1 = 4'b0000; 
            count0 = 4'b0000;
        end
        else if(count0 == 4'b1001) begin
            // 個位數數到 9，個位數歸零，十位數加 1
            count0 = 4'b0000;
            count1 = count1 + 1'b1;
        end
        else begin
            // 一般情況，個位數加 1
            count0 = count0 + 1'b1;
        end
    end
end
endmodule