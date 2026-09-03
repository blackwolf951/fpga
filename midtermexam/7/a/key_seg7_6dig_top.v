// [逐行教學 HEADER] ===============================================================
// [逐行教學 HEADER] 檔案：key_seg7_6dig_top.v
// [逐行教學 HEADER] 主要模組：key_seg7_6dig_top
// [逐行教學 HEADER] 整體用途：鍵盤＋六位七段＋LED Matrix 顯示頂層。
// [逐行教學 HEADER] 每一個「原始實體行」前都加入 [語法] + [用途]，原始程式行本身不修改。
// [逐行教學 HEADER] 若一個原始行塞了多個敘述，註解會把同一行內的宣告/賦值/子模組一起拆解說明。
// [逐行教學 HEADER] ===============================================================
// [逐行教學 L001][語法] `//` 是 Verilog 單行註解；從 `//` 到行尾不參與模擬邏輯或硬體綜合。
// [逐行教學 L001][用途] 保留原作者對題目、接線、狀態或設計意圖的文字說明。
// TOP Q7(a). New key enters the RIGHT side; old digits shift LEFT.
// [逐行教學 L002][語法] `module` 宣告一個硬體模組；模組名稱後括號列出對外 I/O；埠列表直接出現 `input/output`，屬 ANSI-style 埠宣告；`[msb:lsb]`/`[index]`
// [逐行教學 L002][語法] 用來選取向量的一段或單一 bit。
// [逐行教學 L002][用途] 鍵盤＋六位七段＋LED Matrix 顯示頂層。。
module key_seg7_6dig_top(input clk,input rst,input [2:0] column,
// [逐行教學 L003][語法] `output` 宣告由模組送到外部的輸出埠；`[2:0]` 指定位元範圍。
// [逐行教學 L003][用途] 本段宣告：sel=掃描/選擇訊號；seg7=七段段碼；row=LED Matrix 列選；column_green=綠色欄像素。
 output [2:0] sel,output [6:0] seg7,output [7:0] row,output [7:0] column_green,output [7:0] column_red);
// [逐行教學 L004][語法] `wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`[3:0]` 指定位元範圍；`wire`
// [逐行教學 L004][語法] 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`[2:0]` 指定位元範圍。
// [逐行教學 L004][用途] 本段宣告：clk_keyscan, clk_matrix；本段宣告：key_event=有效按鍵事件；本段宣告：key_code=按鍵代碼；本段宣告：row_idx=目前掃描列索引。
 wire clk_keyscan,clk_matrix; wire key_event; wire [3:0] key_code; wire [2:0] row_idx;
// [逐行教學 L005][語法] `reg` 宣告可在 `always/function` 中賦值的程序變數；是否形成 DFF 由 always 類型決定；`[23:0]` 指定位元範圍；`reg` 宣告可在
// [逐行教學 L005][語法] `always/function` 中賦值的程序變數；是否形成 DFF 由 always 類型決定；`[3:0]` 指定位元範圍；`wire` 宣告連線型訊號，通常由 `assign`
// [逐行教學 L005][語法] 或子模組輸出驅動；`[7:0]` 指定位元範圍。
// [逐行教學 L005][用途] 本段宣告：display_code；本段宣告：last_code；本段宣告：digit=目前七段顯示數字；本段宣告：matrix_pixels。
 reg [23:0] display_code; reg [3:0] last_code; reg [3:0] digit; wire [7:0] matrix_pixels;
// [逐行教學 L006][語法] `freq_div UKT(...)` 是子模組實例化；`UKT` 是這一顆硬體實例名稱；`#(14)` 是 parameter
// [逐行教學 L006][語法] override，用新值取代子模組預設參數；`.port(signal)` 是具名 port mapping。
// [逐行教學 L006][用途] 時脈分頻器：利用二進位計數器的某一位，把 FPGA 高速系統時脈降成較慢時脈。。
 freq_div #(14) UKT(.clk_in(clk),.reset(rst),.clk_out(clk_keyscan));
// [逐行教學 L007][語法] `freq_div UMT(...)` 是子模組實例化；`UMT` 是這一顆硬體實例名稱；`#(10)` 是 parameter
// [逐行教學 L007][語法] override，用新值取代子模組預設參數；`.port(signal)` 是具名 port mapping。
// [逐行教學 L007][用途] 時脈分頻器：利用二進位計數器的某一位，把 FPGA 高速系統時脈降成較慢時脈。。
 freq_div #(10) UMT(.clk_in(clk),.reset(rst),.clk_out(clk_matrix));
// [逐行教學 L008][語法] `keypad_event UK(...)` 是子模組實例化；`UK` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping；`1'b1` = 1-bit
// [逐行教學 L008][語法] 二進位常數。
// [逐行教學 L008][用途] 鍵盤事件模組：掃描鍵盤並產生單次 key_event/key_code。。
 keypad_event UK(.clk(clk_keyscan),.reset(rst),.tick_scan(1'b1),.column(column),.sel(sel),.key_event(key_event),.key_code(key_code));
// [逐行教學 L009][語法] `always @(posedge/negedge ...)` 是邊緣觸發的時序程序區塊；監看 clk_keyscan 的上升緣、rst 的上升緣；同一行的 `begin` 開始一個多敘述區塊。
// [逐行教學 L009][用途] 通常綜合成 DFF/暫存器，在指定邊緣更新狀態；Reset 也在敏感度表，因此是非同步重置。
 always @(posedge clk_keyscan or posedge rst) begin
// [逐行教學 L010][語法] `if (rst)` 是條件分支：條件為 1 才執行後續敘述；`display_code <= ...` 使用非阻塞賦值；常用於時序邏輯，先用舊值計算、事件結束時一起更新；`last_code <=
// [逐行教學 L010][語法] ...` 使用非阻塞賦值；常用於時序邏輯，先用舊值計算、事件結束時一起更新；`24'hFFFFFF` = 24-bit 十六進位常數；`4'hF` = 4-bit 十六進位常數。
// [逐行教學 L010][用途] 檢查 `rst` 以決定資料/狀態要走哪一條路徑；這是重置分支；更新 `display_code`，下一值由 `24'hFFFFFF` 計算；更新 `last_code`，下一值由 `4'hF`
// [逐行教學 L010][用途] 計算。
  if(rst) begin display_code<=24'hFFFFFF;last_code<=4'hF;end
// [逐行教學 L011][語法] `if (key_event)` 是條件分支：條件為 1 才執行後續敘述；`else if` 只在前面 if 不成立時繼續測試下一個條件；`else if(...)` 是子模組實例化；`if`
// [逐行教學 L011][語法] 是這一顆硬體實例名稱；`display_code <= ...` 使用非阻塞賦值；常用於時序邏輯，先用舊值計算、事件結束時一起更新；`last_code <= ...`
// [逐行教學 L011][語法] 使用非阻塞賦值；常用於時序邏輯，先用舊值計算、事件結束時一起更新；`{...}` 是 concatenation 位元串接，可把多段 bit 合併/重排；`[msb:lsb]`/`[index]`
// [逐行教學 L011][語法] 用來選取向量的一段或單一 bit。
// [逐行教學 L011][用途] 檢查 `key_event` 以決定資料/狀態要走哪一條路徑；把 `else` 子模組放進目前模組並與內部訊號連線；更新 `display_code`，右式用 `{...}` 串接/重排多段位元；更新
// [逐行教學 L011][用途] `last_code`，下一值由 `key_code` 計算。
  else if(key_event) begin display_code<={display_code[19:0],key_code};last_code<=key_code;end
// [逐行教學 L012][語法] `end` 結束最近一個 `begin` 區塊。
// [逐行教學 L012][用途] 關閉目前條件、時序或組合邏輯區塊。
 end
// [逐行教學 L013][語法] `always @(*)` 自動把區塊內讀到的訊號加入敏感度表，通常描述組合邏輯；同一行的 `begin` 開始一個多敘述區塊；`case(sel)` 是多路選擇語法，依選擇值匹配各個
// [逐行教學 L013][語法] `標籤:`；`endcase` 結束前面的 case 多路選擇區塊；`default:` 是 case 沒有其他標籤匹配時使用的預設分支；`digit = ...`
// [逐行教學 L013][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`[msb:lsb]`/`[index]` 用來選取向量的一段或單一 bit。
// [逐行教學 L013][用途] 任一輸入改變就重新計算本區塊；所有路徑都有賦值時不需要記憶狀態；硬體上通常形成解碼器/MUX，用狀態、按鍵或索引選擇不同輸出；完成目前 case 解碼邏輯；提供未列舉情況的安全輸出/預設動作；更新
// [逐行教學 L013][用途] `digit`（目前七段顯示數字），下一值由 `display_code[23:20]` 計算；更新 `digit`（目前七段顯示數字），下一值由 `display_code[19:16]`
// [逐行教學 L013][用途] 計算；更新 `digit`（目前七段顯示數字），下一值由 `display_code[15:12]` 計算；更新 `digit`（目前七段顯示數字），下一值由 `display_code[11:8]`
// [逐行教學 L013][用途] 計算；更新 `digit`（目前七段顯示數字），下一值由 `display_code[7:4]` 計算；更新 `digit`（目前七段顯示數字），下一值由 `display_code[3:0]`
// [逐行教學 L013][用途] 計算。
 always @(*) begin case(sel) 0:digit=display_code[23:20];1:digit=display_code[19:16];2:digit=display_code[15:12];3:digit=display_code[11:8];4:digit=display_code[7:4];default:digit=display_code[3:0];endcase end
// [逐行教學 L014][語法] `bcd_to_seg7 UDEC(...)` 是子模組實例化；`UDEC` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping。
// [逐行教學 L014][用途] 七段顯示器解碼器：把 4-bit 數字/代碼轉成 a~g 七段亮滅資料。。
 bcd_to_seg7 UDEC(.bcd_in(digit),.seg7(seg7));
// [逐行教學 L015][語法] `matrix_scan USCAN(...)` 是子模組實例化；`USCAN` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping；`1'b1` = 1-bit
// [逐行教學 L015][語法] 二進位常數。
// [逐行教學 L015][用途] 8×8 LED Matrix 掃描器。。
 matrix_scan USCAN(.clk(clk_matrix),.reset(rst),.tick_scan(1'b1),.row_idx(row_idx),.row(row));
// [逐行教學 L016][語法] `numeric_rom UROM(...)` 是子模組實例化；`UROM` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping。
// [逐行教學 L016][用途] 數字字型 ROM。。
 numeric_rom UROM(.code(last_code),.row_idx(row_idx),.data(matrix_pixels));
// [逐行教學 L017][語法] `assign 左式 = 右式;` 是 continuous assignment；這裡的 `=` 屬連續指定，不是 always 內的阻塞賦值；`8'h00` = 8-bit 十六進位常數。
// [逐行教學 L017][用途] 更新 `column_green`（綠色欄像素），下一值由 `matrix_pixels` 計算；右式一變化就立即重新驅動左側 wire；更新 `column_red`（紅色欄像素）為
// [逐行教學 L017][用途] 0/關閉或初始值；右式一變化就立即重新驅動左側 wire。
 assign column_green=matrix_pixels; assign column_red=8'h00;
// [逐行教學 L018][語法] `endmodule` 與前面的 `module` 配對，結束模組定義。
// [逐行教學 L018][用途] 結束 `key_seg7_6dig_top` 的 RTL 描述。
endmodule
