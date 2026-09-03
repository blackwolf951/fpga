// [逐行教學 HEADER] ===============================================================
// [逐行教學 HEADER] 檔案：flow3_top.v
// [逐行教學 HEADER] 主要模組：flow3_top
// [逐行教學 HEADER] 整體用途：流水顯示頂層：整合分頻器與 flow3。
// [逐行教學 HEADER] 每一個「原始實體行」前都加入 [語法] + [用途]，原始程式行本身不修改。
// [逐行教學 HEADER] 若一個原始行塞了多個敘述，註解會把同一行內的宣告/賦值/子模組一起拆解說明。
// [逐行教學 HEADER] ===============================================================
// [逐行教學 L001][語法] `//` 是 Verilog 單行註解；從 `//` 到行尾不參與模擬邏輯或硬體綜合。
// [逐行教學 L001][用途] 保留原作者對題目、接線、狀態或設計意圖的文字說明。
// TOP Q6: 3 consecutive green pixels on the LEFT column, top->bottom->top, pauseable.
// [逐行教學 L002][語法] `module` 宣告一個硬體模組；模組名稱後括號列出對外 I/O；埠列表直接出現 `input/output`，屬 ANSI-style 埠宣告；`[msb:lsb]`/`[index]`
// [逐行教學 L002][語法] 用來選取向量的一段或單一 bit。
// [逐行教學 L002][用途] 流水顯示頂層：整合分頻器與 flow3。。
module flow3_top(input clk,input reset,input enable,output [7:0] row,output [7:0] column_green,output [7:0] column_red);
// [逐行教學 L003][語法] `wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`[2:0]` 指定位元範圍。
// [逐行教學 L003][用途] 本段宣告：clk_move, clk_scan；本段宣告：row_idx=目前掃描列索引；本段宣告：dir。
 wire clk_move,clk_scan; wire [2:0] pos,row_idx; wire dir;
// [逐行教學 L004][語法] `freq_div UM(...)` 是子模組實例化；`UM` 是這一顆硬體實例名稱；`#(21)` 是 parameter override，用新值取代子模組預設參數；`.port(signal)`
// [逐行教學 L004][語法] 是具名 port mapping。
// [逐行教學 L004][用途] 時脈分頻器：利用二進位計數器的某一位，把 FPGA 高速系統時脈降成較慢時脈。。
 freq_div #(21) UM(.clk_in(clk),.reset(reset),.clk_out(clk_move)); // about 4.8 steps/s
// [逐行教學 L005][語法] `freq_div US(...)` 是子模組實例化；`US` 是這一顆硬體實例名稱；`#(10)` 是 parameter override，用新值取代子模組預設參數；`.port(signal)`
// [逐行教學 L005][語法] 是具名 port mapping。
// [逐行教學 L005][用途] 時脈分頻器：利用二進位計數器的某一位，把 FPGA 高速系統時脈降成較慢時脈。。
 freq_div #(10) US(.clk_in(clk),.reset(reset),.clk_out(clk_scan));
// [逐行教學 L006][語法] `flow3 UF(...)` 是子模組實例化；`UF` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping；`1'b1` = 1-bit 二進位常數。
// [逐行教學 L006][用途] 三段流水圖樣核心。。
 flow3 UF(.clk(clk_move),.reset(reset),.tick_move(1'b1),.enable(enable),.pos(pos),.direction_down(dir));
// [逐行教學 L007][語法] `matrix_scan UR(...)` 是子模組實例化；`UR` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping；`1'b1` = 1-bit 二進位常數。
// [逐行教學 L007][用途] 8×8 LED Matrix 掃描器。。
 matrix_scan UR(.clk(clk_scan),.reset(reset),.tick_scan(1'b1),.row_idx(row_idx),.row(row));
// [逐行教學 L008][語法] `assign 左式 = 右式;` 是 continuous assignment；這裡的 `=` 屬連續指定，不是 always 內的阻塞賦值；`row_idx <= ...`
// [逐行教學 L008][語法] 使用非阻塞賦值；常用於時序邏輯，先用舊值計算、事件結束時一起更新；`8'b1000_0000` = 8-bit 二進位常數；`8'h00` = 8-bit 十六進位常數；`&&` 是邏輯
// [逐行教學 L008][語法] AND：兩個條件都成立才為真；`條件 ? A : B` 是三元條件運算子，硬體上等效於 2-to-1 MUX。
// [逐行教學 L008][用途] 更新 `column_green`（綠色欄像素），右式用三元運算依條件選一個來源（MUX）；右式一變化就立即重新驅動左側 wire；更新
// [逐行教學 L008][用途] `row_idx`（目前掃描列索引），右式用三元運算依條件選一個來源（MUX）。
 assign column_green=((row_idx>=pos)&&(row_idx<=pos+2))?8'b1000_0000:8'h00;
// [逐行教學 L009][語法] `assign 左式 = 右式;` 是 continuous assignment；這裡的 `=` 屬連續指定，不是 always 內的阻塞賦值；`8'h00` = 8-bit 十六進位常數。
// [逐行教學 L009][用途] 更新 `column_red`（紅色欄像素）為 0/關閉或初始值；右式一變化就立即重新驅動左側 wire。
 assign column_red=8'h00;
// [逐行教學 L010][語法] `endmodule` 與前面的 `module` 配對，結束模組定義。
// [逐行教學 L010][用途] 結束 `flow3_top` 的 RTL 描述。
endmodule
