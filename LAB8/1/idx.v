// ============================================================
// 檔名: idx.v   【狀態：投影片已給完整程式碼，邏輯正確，僅補充註解】
// 功能: 每個 clk 上升緣，idx(0~7,3bit) 加1，同時 row(8bit one-hot) 也跟著循環右移一位，
//       兩者是同步的：idx 用來當地圖(map.v)的列位址，row 用來實際驅動8x8點矩陣的列選擇線
// 注意: 頂層模組呼叫這個模組時，clk 建議接「快速時脈」(FPGA原始時脈，例如50MHz)，
//       不要接分頻後的慢速時脈 ck。
//       因為 row 同時也是拿去驅動 LED 硬體做「多工掃描(multiplexing)」用的，
//       掃描速度必須夠快(每一列切換要在人眼殘影時間內完成一輪8列)，
//       否則畫面會出現閃爍或某幾列偏暗的情況。
// ============================================================
module  idx(clk, reset, idx, row);
input        reset, clk;
output reg  [2:0]idx;
output reg  [7:0]row;
always@(posedge clk or posedge reset)
begin
    if(reset) begin
        idx<=3'b000;
        row<=8'b1000_0000;
    end
    else begin
        idx<=idx+3'b001;
        row<={row[0],row[7:1]};   // 把最低位元轉到最高位元，其餘右移一位 -> 循環右移
    end
end
endmodule
