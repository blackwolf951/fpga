// ============================================================================
// [教學註解] 檔案：row_gen.v
// [教學註解] 模組：row_gen
// [教學註解] 功能：LED 點矩陣列掃描產生器：把索引轉換成 one-hot/掃描列訊號。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module row_gen(clk, rst, idx, row, idx_cnt);
    // [教學註解] 輸入埠：clk=系統時脈；rst=系統重置。
    input clk, rst;
    // [教學註解] 輸入埠：idx=目前掃描列索引。
    input [6:0] idx;
    // [教學註解] 輸出埠：row=8×8 列掃描訊號。
    output [7:0] row;
    // [教學註解] 輸出埠：宣告此區塊中使用的訊號與位元寬度。
    output [6:0] idx_cnt;
    
    // [教學註解] 程序賦值暫存型訊號(reg)：row=8×8 列掃描訊號。
    reg [7:0] row;
    // [教學註解] 程序賦值暫存型訊號(reg)：宣告此區塊中使用的訊號與位元寬度。
    reg [6:0] idx_cnt;
    // [教學註解] 程序賦值暫存型訊號(reg)：宣告此區塊中使用的訊號與位元寬度。
    reg [2:0] cnt;
    
    // [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
    always @(posedge clk or posedge rst) begin
        // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
        if (rst) begin
            row <= 8'b1000_0000; // 修正1：依據講義，初始必須是 1000_0000 (致能第一排)
            cnt <= 3'd0;
            idx_cnt <= 7'd0;
        end
        else begin
            // [教學註解] 串接運算 { } 重新排列位元，可用來實作移位或把多個欄位合併成一個匯流排。
            row <= {row[0], row[7:1]};  // 循環右移：1000_0000 -> 0100_0000 (掃描下一排)
            cnt <= cnt + 3'd1;          // 計數器 0 到 7 循環
            
            // 修正2：精準對齊下一個時脈的資料，並防止 cnt+1 變成 8 抓到錯的圖
            if (cnt == 3'd7)
                idx_cnt <= idx;         // 當數到最後一排(7)準備回到第一排(0)時，直接抓取第一排的起始 idx
            else
                idx_cnt <= idx + cnt + 7'd1; // 否則抓取下一排的資料 (idx + cnt + 1)
        end
    end
endmodule





/*module row_gen(clk, rst, idx, row, idx_cnt);
    input clk, rst;
    input [6:0] idx;
    output [7:0] row;
    output [6:0] idx_cnt;
    
    reg [7:0] row;
    reg [6:0] idx_cnt;
    reg [2:0] cnt;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row <= 8'b0000_0001; 
            cnt <= 3'd0;
            idx_cnt <= 7'd0;
        end
        else begin
            row <= {row[0], row[7:1]};   // (輪流將每一列LED致能) - 循環位移
            cnt <= cnt + 3'd1;           // (從0數到7) 
            idx_cnt <= idx + cnt + 3'd1; // (將初始位置加0到7) - 為了與更新後的 cnt 同步，這裡直接 + 1
        end
    end
endmodule*/