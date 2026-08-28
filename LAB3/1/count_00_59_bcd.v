// ============================================================================
// [教學註解] 檔案：count_00_59_bcd.v
// [教學註解] 模組：count_00_59_bcd
// [教學註解] 功能：兩位 BCD 60 進位計數器：計數範圍 00~59，適合秒/分鐘。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module count_00_59_bcd(clk, reset, enable, count1, count0, carry);
// [教學註解] 輸入埠：clk=系統時脈；reset=系統重置；enable=致能控制。
input clk, reset, enable;
// [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
output [3:0] count1, count0;
// [教學註解] 程序賦值暫存型訊號(reg)：宣告此區塊中使用的訊號與位元寬度。
reg[3:0] count1, count0;
// [教學註解] 輸出埠：carry=進位訊號。
output carry;


// [教學註解] 連接線(wire)：carry=進位訊號。
wire carry = (count1 == 4'b0101 && count0 == 4'b1001 && enable == 1'b1) ? 1'b1 : 1'b0;
//因為沒有加上 enable 的條件，當分鐘數到 59 時，
//它的 carry 會在整個第 59 分鐘內長達 60 秒都保持開啟。
//這導致你的「小時」模組在這 60 秒內連續收到了 60 次進位訊號，60 除以 24 餘數剛好是 12，所以小時就會瞬間跳 12 步然後停住！

// 當數到 59 時 (十位數5=0101, 個位數9=1001)，發出進位訊號給下一個模組
//wire carry = (count1 == 4'b0101 && count0 == 4'b1001) ? 1 : 0; 

// [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
always@ (posedge clk or posedge reset)
begin
    // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
    if(reset) begin
        count1 = 4'b0000; // 00
        count0 = 4'b0000;
    end
    // [教學註解] enable 成立才執行主要動作；enable=0 時通常保持目前狀態。
    else if(enable == 1'b1) begin
        if (count1 == 4'b0101 && count0 == 4'b1001) begin
            // 數到 59，下一個 clock 歸零
            count1 = 4'b0000; 
            count0 = 4'b0000;
        end
        else if(count0 == 4'b1001) begin
            // 個位數數到 9，個位數歸零，十位數加 1
            count0 = 4'b0000;
            // [教學註解] 計數 +1：每次有效時脈事件讓目前數值增加一。
            count1 = count1 + 1'b1;
        end
        else begin
            // 一般情況，個位數加 1
            count0 = count0 + 1'b1;
        end
    end
end
endmodule