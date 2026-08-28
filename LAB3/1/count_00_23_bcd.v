// ============================================================================
// [教學註解] 檔案：count_00_23_bcd.v
// [教學註解] 模組：count_00_23_bcd
// [教學註解] 功能：兩位 BCD 24 進位計數器：計數範圍 00~23，適合小時。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module count_00_23_bcd(clk, reset, enable, count1, count0, carry);
// [教學註解] 輸入埠：clk=系統時脈；reset=系統重置；enable=致能控制。
input clk, reset, enable;
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output [3:0] count1, count0;
// [教學註解] 程序賦值暫存型訊號(reg)：宣告此區塊中使用的訊號與位元寬度。
reg[3:0] count1, count0;
// [教學註解] 輸出埠：carry=進位訊號。
output carry;
// ...前面省略[cite: 9]

// 為了程式碼完整性，小時的模組也建議補上正確的 carry 輸出
// [教學註解] 連接線(wire)：carry=進位訊號。
wire carry = (count1 == 4'b0010 && count0 == 4'b0011 && enable == 1'b1) ? 1'b1 : 1'b0;

// [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
always@ (posedge clk or posedge reset) begin
    // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
    if(reset) begin
        count1 = 4'b0000; // 歸零
        count0 = 4'b0000;
    end
    // [教學註解] enable 成立才執行主要動作；enable=0 時通常保持目前狀態。
    else if(enable == 1'b1) begin
        // 當數到 23 時，下一次進位要歸零[cite: 9]
        if (count1 == 4'b0010 && count0 == 4'b0011) begin 
            count1 = 4'b0000; 
            count0 = 4'b0000;
        end
        // 當個位數數到 9 時，個位歸零，十位進 1[cite: 9]
        else if(count0 == 4'b1001) begin 
            count0 = 4'b0000;
            // [教學註解] 計數 +1：每次有效時脈事件讓目前數值增加一。
            count1 = count1 + 1'b1;
        end
        // 一般情況下，個位數加 1[cite: 9]
        else begin 
            // [教學註解] 計數 +1：每次有效時脈事件讓目前數值增加一。
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