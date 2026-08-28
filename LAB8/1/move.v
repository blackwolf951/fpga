// ============================================================
// 檔名: move.v （已修正）
// 功能: 依 keycode(2,4,6,8) 解出 left/right/up/down 四個方向信號，
//       再各用一個 shift 模組控制水平(hor)與垂直(ver)方向的紅點位置
// 修正重點:
//   PPT 原本給的 assign right=keycode[1]&keycode[2]; assign down=keycode[3];
//   在 keycode=4'b1111(沒有按鍵)時會誤判成 right=1, down=1，
//   導致紅點在沒按鍵時就自己往右下移動。
//   改成「精確比對」，只有真的等於 0010/0100/0110/1000 才會動作，
//   其餘情況(包含1111)一律不動。
// ============================================================
module  move(reset, unable, keycode, ver, hor, clk);
input       reset, clk, unable;
input       [3:0]keycode;
output  [7:0]ver, hor;
wire        left, right, up, down;

// keycode: 0010=上 0100=左 0110=右 1000=下
assign  left  = (keycode == 4'b0100);   // 4 -> 左
assign  right = (keycode == 4'b0110);   // 6 -> 右
assign  up    = (keycode == 4'b0010);   // 2 -> 上
assign  down  = (keycode == 4'b1000);   // 8 -> 下

shift S1(left,  right, reset, unable, hor, clk); //left & right -> 控制水平位置 hor
shift S2(up,    down,  reset, unable, ver, clk); //up & down    -> 控制垂直位置 ver

endmodule
