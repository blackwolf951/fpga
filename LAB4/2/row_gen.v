module row_gen(clk, rst, idx, row, idx_cnt);
    input clk, rst;
    input [6:0] idx;
    output [7:0] row;
    output [6:0] idx_cnt;
    
    reg [7:0] row;
    reg [6:0] idx_cnt;
    reg [2:0] cnt;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row <= 8'b1000_0000; // 修正1：依據講義，初始必須是 1000_0000 (致能第一排)
            cnt <= 3'd0;
            idx_cnt <= 7'd0;
        end
        else begin
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