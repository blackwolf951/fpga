module count_00_23_bcd(clk, reset, enable, count1, count0, carry);
input clk, reset, enable;
output [3:0] count1, count0;
reg[3:0] count1, count0;
output carry;
// ...前面省略[cite: 9]

// 為了程式碼完整性，小時的模組也建議補上正確的 carry 輸出
wire carry = (count1 == 4'b0010 && count0 == 4'b0011 && enable == 1'b1) ? 1'b1 : 1'b0;

always@ (posedge clk or posedge reset) begin
    if(reset) begin
        count1 = 4'b0000; // 歸零
        count0 = 4'b0000;
    end
    else if(enable == 1'b1) begin
        // 當數到 23 時，下一次進位要歸零[cite: 9]
        if (count1 == 4'b0010 && count0 == 4'b0011) begin 
            count1 = 4'b0000; 
            count0 = 4'b0000;
        end
        // 當個位數數到 9 時，個位歸零，十位進 1[cite: 9]
        else if(count0 == 4'b1001) begin 
            count0 = 4'b0000;
            count1 = count1 + 1'b1;
        end
        // 一般情況下，個位數加 1[cite: 9]
        else begin 
            count0 = count0 + 1'b1;
        end
    end
end
endmodule







 //為什麼會「一次跳 12」？ (兇手是進位訊號)在串接時鐘（clock.v）時，你的「秒」、「分」、「時」三個模組，都是共用同一個計數時脈 clk_count。
//依照講義的寫法，count_00_59_bcd 產生進位 (carry) 的條件是：
//wire carry = (count1 == 4'b0101 && count0 == 4'b1001) ? 1 : 0;  這個寫法隱藏了一個致命的連鎖反應：分鐘停滯：當「分鐘」數到 59 時，它必須等待「秒數」走完 00~59 才會進位。所以「分鐘」會維持在 59 長達 60 秒。長達 60 秒的 Enable：因為「分鐘」的 carry1 只要看到 59 就會變成 1，這導致 carry1 在這 60 秒內永遠保持高電位。小時狂飆：「小時」模組（count_00_23_bcd）把 carry1 當作自己的 enable。在 enable 保持開啟的這 60 秒內，只要 clk_count 敲一下（如果是 1Hz，就是每秒敲一下），小時就會加 1。  數學的巧合：在這 1 分鐘內，你的小時被加了 60 次。60 除以 24，餘數剛好是 12！這就是在視覺上，你的小時數會從 0 瞬間跳到 12，再從 12 瞬間跳到 00 的真正原因。







//module count_00_23_bcd(clk, reset, enable, count1, count0, carry);
//input clk, reset, enable;
//output [3:0] count1, count0;
//reg[3:0] count1, count0;
//output carry;
// ...前面省略[cite: 9]
//always@ (posedge clk or posedge reset) begin
//    if(reset) begin
//        count1 = 4'b0000; // 歸零
//        count0 = 4'b0000;
//    end
//    else if(enable == 1'b1) begin
        // 當數到 23 時，下一次進位要歸零[cite: 9]
//        if (count1 == 4'b0010 && count0 == 4'b0011) begin 
//            count1 = 4'b0000; 
//            count0 = 4'b0000;
//        end
        // 當個位數數到 9 時，個位歸零，十位進 1[cite: 9]
//        else if(count0 == 4'b1001) begin 
//            count0 = 4'b0000;
//            count1 = count1 + 1'b1;
//        end
        // 一般情況下，個位數加 1[cite: 9]
//        else begin 
//            count0 = count0 + 1'b1;
//        end
//    end
//end
//endmodule