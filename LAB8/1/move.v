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

// ============================================================================
// [教學註解] 檔案：move.v
// [教學註解] 模組：move
// [教學註解] 功能：紅點移動控制：將鍵碼解成上下左右方向，驅動水平/垂直移位暫存器。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module  move(reset, unable, keycode, ver, hor, clk);
// [教學註解] 輸入埠：reset=系統重置；clk=系統時脈；unable=禁止移動控制。
input       reset, clk, unable;
// [教學註解] 輸入埠：keycode=鎖存後的按鍵碼。
input       [3:0]keycode;
// [教學註解] 輸出埠：ver=紅點垂直 one-hot 位置；hor=紅點水平 one-hot 位置。
output  [7:0]ver, hor;
// [教學註解] 連接線(wire)：left=左移控制；right=右移控制；up=上移控制；down=下移控制。
wire        left, right, up, down;

// keycode: 0010=上 0100=左 0110=右 1000=下
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign  left  = (keycode == 4'b0100);   // 4 -> 左
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign  right = (keycode == 4'b0110);   // 6 -> 右
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign  up    = (keycode == 4'b0010);   // 2 -> 上
// [教學註解] 連續指定(assign)：描述組合邏輯連線，右式改變時左式會立即重新計算。
assign  down  = (keycode == 4'b1000);   // 8 -> 下

// [教學註解] 實例化 shift（S1）：把此子模組接進目前階層，完成「位置移位暫存器：依左右/上下控制讓 one-hot 位置位元移動，並可被 reset/unable 控制。」
shift S1(left,  right, reset, unable, hor, clk); //left & right -> 控制水平位置 hor
// [教學註解] 實例化 shift（S2）：把此子模組接進目前階層，完成「位置移位暫存器：依左右/上下控制讓 one-hot 位置位元移動，並可被 reset/unable 控制。」
shift S2(up,    down,  reset, unable, ver, clk); //up & down    -> 控制垂直位置 ver

endmodule
