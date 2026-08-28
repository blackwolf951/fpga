// ============================================================
// 檔名: key_buf.v （已修正）
// 功能: 當 press_valid 有效脈波出現時，把 scan_code 鎖存(latch)成 keycode，
//       供 move.v 判斷目前要往哪個方向移動
// 修正重點:
//   原本 else 分支寫 keycode<=keycode(保持上一次的值)，
//   會造成「按一下某個方向鍵，之後永遠不會停」，因為 keycode 永遠不會
//   回到代表「沒有按鍵」的 1111。
//   改成 else 時回到 4'b1111，這樣紅點只有在偵測到新的有效按鍵事件時才會走，
//   放開按鍵之後(沒有新的 press_valid)就會停下來。
// ============================================================
module key_buf(clk, rst, press_valid, scan_code, keycode);
    input clk, rst, press_valid;
    input [3:0] scan_code;
    output reg [3:0] keycode;

    always@(posedge clk or posedge rst) begin
        if(rst)
            keycode <= 4'b1111;              // 重置為「沒有鍵被按下」的碼
        else if(press_valid)
            keycode <= scan_code;            // 偵測到有效按鍵才更新keycode
        else
            keycode <= 4'b1111;              // 沒有新的按鍵事件 -> 回到無按鍵，紅點停止
    end
endmodule
