// ============================================================
// 檔名: collision.v   【狀態：投影片已給完整程式碼，邏輯正確，僅補充註解】
// 功能: 偵測目前掃描到的紅點(red)是否與牆壁(green)重疊 -> 判斷撞牆
// 注意: 頂層模組呼叫這個模組時，clk 必須接「快速時脈」(和 idx.v 同一顆)，
//       不能接分頻後的慢速時脈 ck，否則 red 訊號只在極短暫的瞬間才會非0，
//       慢速時脈很容易「取樣不到」，導致永遠偵測不到撞牆。
// ============================================================
module  collision(clk, reset, red, green, coll);
input       clk, reset;
input       [7:0]red, green;
output reg  coll;
always@(posedge clk or posedge reset)
begin
    if(reset)
        coll<=1'b0;
    else if((red & green) != 8'b0)    //發生碰撞：紅點所在的位元與牆壁位元同時為1
        coll<=1'b1;
    else
        coll<=coll;   // 說明：coll 一旦變成1就會鎖住(latch)，直到reset才會清除
                       // 這是刻意設計：撞牆後畫面凍結，需要按reset才能重新開始
end
endmodule
