// [逐行教學 HEADER] ===============================================================
// [逐行教學 HEADER] 檔案：traffic_top.v
// [逐行教學 HEADER] 主要模組：traffic_top
// [逐行教學 HEADER] 整體用途：交通號誌頂層：整合號誌、行人動畫與七段倒數。
// [逐行教學 HEADER] 每一個「原始實體行」前都加入 [語法] + [用途]，原始程式行本身不修改。
// [逐行教學 HEADER] 若一個原始行塞了多個敘述，註解會把同一行內的宣告/賦值/子模組一起拆解說明。
// [逐行教學 HEADER] ===============================================================
// [逐行教學 L001][語法] `//` 是 Verilog 單行註解；從 `//` 到行尾不參與模擬邏輯或硬體綜合。
// [逐行教學 L001][用途] 保留原作者對題目、接線、狀態或設計意圖的文字說明。
// TOP Q9(a). light bits are {L1,L2,L3,L4,L5,L6}; L7-L12 are off.
// [逐行教學 L002][語法] `//` 是 Verilog 單行註解；從 `//` 到行尾不參與模擬邏輯或硬體綜合。
// [逐行教學 L002][用途] 保留原作者對題目、接線、狀態或設計意圖的文字說明。
// Day: direction-1 follows exam rounds, direction-2 is red while dir-1 is G/Y and green while dir-1 is red.
// [逐行教學 L003][語法] `//` 是 Verilog 單行註解；從 `//` 到行尾不參與模擬邏輯或硬體綜合。
// [逐行教學 L003][用途] 保留原作者對題目、接線、狀態或設計意圖的文字說明。
// Seven-seg shows 4-digit red-side countdown 0020..0001. Night: yellow LEDs + yellow pedestrian blink.
// [逐行教學 L004][語法] `module` 宣告一個硬體模組；模組名稱後括號列出對外 I/O；埠列表直接出現 `input/output`，屬 ANSI-style 埠宣告。
// [逐行教學 L004][用途] 交通號誌頂層：整合號誌、行人動畫與七段倒數。。
module traffic_top(input clk,input rst,input day_night,
// [逐行教學 L005][語法] `output` 宣告由模組送到外部的輸出埠；`[11:0]` 指定位元範圍。
// [逐行教學 L005][用途] 本段宣告：seg7_out=七段段碼；seg7_sel=七段位選。
 output [11:0] light_led,output led_com,output [6:0] seg7_out,output [2:0] seg7_sel,
// [逐行教學 L006][語法] `output` 宣告由模組送到外部的輸出埠；`[7:0]` 指定位元範圍；`output reg` 允許此輸出在 always 程序區塊被賦值。
// [逐行教學 L006][用途] 本段宣告：matrix_row, matrix_red_col。
 output [7:0] matrix_row,output reg [7:0] matrix_red_col,output reg [7:0] matrix_green_col);
// [逐行教學 L007][語法] `wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`reg` 宣告可在 `always/function` 中賦值的程序變數；是否形成 DFF 由 always
// [逐行教學 L007][語法] 類型決定；`reg` 宣告可在 `always/function` 中賦值的程序變數；是否形成 DFF 由 always 類型決定；`[1:0]` 指定位元範圍。
// [逐行教學 L007][用途] 本段宣告：clk_1hz, clk_2hz, clk_4hz, clk_seg, clk_matrix；本段宣告：blink；本段宣告：phase。
 wire clk_1hz,clk_2hz,clk_4hz,clk_seg,clk_matrix; reg blink; reg [1:0] phase;
// [逐行教學 L008][語法] `wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`[1:0]` 指定位元範圍；`wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`[5:0]`
// [逐行教學 L008][語法] 指定位元範圍；`reg` 宣告可在 `always/function` 中賦值的程序變數；是否形成 DFF 由 always 類型決定；`[5:0]` 指定位元範圍；`wire`
// [逐行教學 L008][語法] 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`[2:0]` 指定位元範圍。
// [逐行教學 L008][用途] 本段宣告：mode=工作模式；本段宣告：remain=剩餘秒數；red_count=紅燈倒數；本段宣告：lights；本段宣告：row_idx=目前掃描列索引。
 wire [1:0] mode; wire [5:0] remain,red_count; reg [5:0] lights; wire [2:0] row_idx;
// [逐行教學 L009][語法] `reg` 宣告可在 `always/function` 中賦值的程序變數；是否形成 DFF 由 always 類型決定；`[3:0]` 指定位元範圍；`reg` 宣告可在
// [逐行教學 L009][語法] `always/function` 中賦值的程序變數；是否形成 DFF 由 always 類型決定；`[1:0]` 指定位元範圍；`reg` 宣告可在 `always/function`
// [逐行教學 L009][語法] 中賦值的程序變數；是否形成 DFF 由 always 類型決定；`wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`[7:0]` 指定位元範圍。
// [逐行教學 L009][用途] 本段宣告：frame=動畫影格；本段宣告：color；本段宣告：show；本段宣告：walkdata, reddata；本段宣告：digit=目前七段顯示數字。
 reg [3:0] frame; reg [1:0] color; reg show; wire [7:0] walkdata,reddata; reg [3:0] digit;
// [逐行教學 L010][語法] `assign 左式 = 右式;` 是 continuous assignment；這裡的 `=` 屬連續指定，不是 always 內的阻塞賦值；`1'b1` = 1-bit
// [逐行教學 L010][語法] 二進位常數；`6'b000000` = 6-bit 二進位常數；`{...}` 是 concatenation 位元串接，可把多段 bit 合併/重排。
// [逐行教學 L010][用途] 更新 `led_com`，下一值由 `1'b1` 計算；右式一變化就立即重新驅動左側 wire；更新 `light_led`，右式用 `{...}` 串接/重排多段位元；右式一變化就立即重新驅動左側
// [逐行教學 L010][用途] wire。
 assign led_com=1'b1; assign light_led={6'b000000,lights};
// [逐行教學 L011][語法] `freq_div_1s U1(...)` 是子模組實例化；`U1` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping。
// [逐行教學 L011][用途] 1 秒時基產生器：把系統時脈轉成約 1 Hz 的秒節拍。。
 freq_div_1s U1(.clk_in(clk),.reset(rst),.clk_out(clk_1hz));
// [逐行教學 L012][語法] `freq_div U4(...)` 是子模組實例化；`U4` 是這一顆硬體實例名稱；`#(21)` 是 parameter override，用新值取代子模組預設參數；`.port(signal)`
// [逐行教學 L012][語法] 是具名 port mapping。
// [逐行教學 L012][用途] 時脈分頻器：利用二進位計數器的某一位，把 FPGA 高速系統時脈降成較慢時脈。。
 freq_div #(21) U4(.clk_in(clk),.reset(rst),.clk_out(clk_4hz));
// [逐行教學 L013][語法] `freq_div U2(...)` 是子模組實例化；`U2` 是這一顆硬體實例名稱；`#(22)` 是 parameter override，用新值取代子模組預設參數；`.port(signal)`
// [逐行教學 L013][語法] 是具名 port mapping。
// [逐行教學 L013][用途] 時脈分頻器：利用二進位計數器的某一位，把 FPGA 高速系統時脈降成較慢時脈。。
 freq_div #(22) U2(.clk_in(clk),.reset(rst),.clk_out(clk_2hz));
// [逐行教學 L014][語法] `freq_div USEGT(...)` 是子模組實例化；`USEGT` 是這一顆硬體實例名稱；`#(12)` 是 parameter
// [逐行教學 L014][語法] override，用新值取代子模組預設參數；`.port(signal)` 是具名 port mapping。
// [逐行教學 L014][用途] 時脈分頻器：利用二進位計數器的某一位，把 FPGA 高速系統時脈降成較慢時脈。。
 freq_div #(12) USEGT(.clk_in(clk),.reset(rst),.clk_out(clk_seg));
// [逐行教學 L015][語法] `freq_div UMT(...)` 是子模組實例化；`UMT` 是這一顆硬體實例名稱；`#(10)` 是 parameter
// [逐行教學 L015][語法] override，用新值取代子模組預設參數；`.port(signal)` 是具名 port mapping。
// [逐行教學 L015][用途] 時脈分頻器：利用二進位計數器的某一位，把 FPGA 高速系統時脈降成較慢時脈。。
 freq_div #(10) UMT(.clk_in(clk),.reset(rst),.clk_out(clk_matrix));
// [逐行教學 L016][語法] `always @(posedge/negedge ...)` 是邊緣觸發的時序程序區塊；監看 clk_2hz 的上升緣、rst 的上升緣；同一行的 `begin` 開始一個多敘述區塊；`if
// [逐行教學 L016][語法] (rst)` 是條件分支：條件為 1 才執行後續敘述；`else` 是前面條件都不成立時執行的備援分支；`blink <= ...`
// [逐行教學 L016][語法] 使用非阻塞賦值；常用於時序邏輯，先用舊值計算、事件結束時一起更新；`~` 是逐位元反相。
// [逐行教學 L016][用途] 通常綜合成 DFF/暫存器，在指定邊緣更新狀態；Reset 也在敏感度表，因此是非同步重置；檢查 `rst` 以決定資料/狀態要走哪一條路徑；這是重置分支；更新 `blink`為
// [逐行教學 L016][用途] 0/關閉或初始值；更新 `blink`，下一值由 `~blink` 計算。
 always @(posedge clk_2hz or posedge rst) begin if(rst) blink<=0; else blink<=~blink; end
// [逐行教學 L017][語法] `always @(posedge/negedge ...)` 是邊緣觸發的時序程序區塊；監看 clk_4hz 的上升緣、rst 的上升緣；同一行的 `begin` 開始一個多敘述區塊；`if
// [逐行教學 L017][語法] (rst)` 是條件分支：條件為 1 才執行後續敘述；`else` 是前面條件都不成立時執行的備援分支；`phase <= ...`
// [逐行教學 L017][語法] 使用非阻塞賦值；常用於時序邏輯，先用舊值計算、事件結束時一起更新；`1'b1` = 1-bit 二進位常數。
// [逐行教學 L017][用途] 通常綜合成 DFF/暫存器，在指定邊緣更新狀態；Reset 也在敏感度表，因此是非同步重置；檢查 `rst` 以決定資料/狀態要走哪一條路徑；這是重置分支；更新 `phase`為
// [逐行教學 L017][用途] 0/關閉或初始值；更新 `phase`為舊值 +1，完成向上計數。
 always @(posedge clk_4hz or posedge rst) begin if(rst) phase<=0; else phase<=phase+1'b1; end
// [逐行教學 L018][語法] `traffic_core UC(...)` 是子模組實例化；`UC` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping；`1'b1` = 1-bit
// [逐行教學 L018][語法] 二進位常數。
// [逐行教學 L018][用途] 交通號誌狀態/倒數核心。。
 traffic_core UC(.clk(clk_1hz),.reset(rst),.tick_1hz(1'b1),.day_night(day_night),.mode(mode),.remain(remain),.red_count(red_count));
// [逐行教學 L019][語法] `always @(*)` 自動把區塊內讀到的訊號加入敏感度表，通常描述組合邏輯；同一行的 `begin` 開始一個多敘述區塊。
// [逐行教學 L019][用途] 任一輸入改變就重新計算本區塊；所有路徑都有賦值時不需要記憶狀態。
 always @(*) begin
// [逐行教學 L020][語法] `if (!day_night)` 是條件分支：條件為 1 才執行後續敘述；`lights = ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`1'b0` =
// [逐行教學 L020][語法] 1-bit 二進位常數；`1'b0` = 1-bit 二進位常數；`1'b0` = 1-bit 二進位常數；`1'b0` = 1-bit 二進位常數；`{...}` 是 concatenation
// [逐行教學 L020][語法] 位元串接，可把多段 bit 合併/重排。
// [逐行教學 L020][用途] 檢查 `!day_night` 以決定資料/狀態要走哪一條路徑；更新 `lights`，右式用 `{...}` 串接/重排多段位元。
  if(!day_night) lights={1'b0,blink,1'b0,1'b0,blink,1'b0};
// [逐行教學 L021][語法] `else` 是前面條件都不成立時執行的備援分支；`case(mode)` 是多路選擇語法，依選擇值匹配各個 `標籤:`；`endcase` 結束前面的 case 多路選擇區塊；`default:`
// [逐行教學 L021][語法] 是 case 沒有其他標籤匹配時使用的預設分支；`else case(...)` 是子模組實例化；`case` 是這一顆硬體實例名稱；`lights = ...`
// [逐行教學 L021][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`6'b001100` = 6-bit 二進位常數；`2'b00` = 2-bit 二進位常數；`1'b1` = 1-bit
// [逐行教學 L021][語法] 二進位常數；`2'b00` = 2-bit 二進位常數；`{...}` 是 concatenation 位元串接，可把多段 bit 合併/重排。
// [逐行教學 L021][用途] 硬體上通常形成解碼器/MUX，用狀態、按鍵或索引選擇不同輸出；完成目前 case 解碼邏輯；提供未列舉情況的安全輸出/預設動作；把 `else` 子模組放進目前模組並與內部訊號連線；更新
// [逐行教學 L021][用途] `lights`，下一值由 `6'b001100` 計算；更新 `lights`，右式用 `{...}` 串接/重排多段位元；更新 `lights`，下一值由 `6'b010100` 計算；更新
// [逐行教學 L021][用途] `lights`，下一值由 `6'b100001` 計算。
  else case(mode) 0:lights=6'b001100;1:lights={2'b00,blink,1'b1,2'b00};2:lights=6'b010100;default:lights=6'b100001; endcase
// [逐行教學 L022][語法] `end` 結束最近一個 `begin` 區塊。
// [逐行教學 L022][用途] 關閉目前條件、時序或組合邏輯區塊。
 end
// [逐行教學 L023][語法] `always @(*)` 自動把區塊內讀到的訊號加入敏感度表，通常描述組合邏輯；同一行的 `begin` 開始一個多敘述區塊；`frame = ...`
// [逐行教學 L023][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`color = ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`show =
// [逐行教學 L023][語法] ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function。
// [逐行教學 L023][用途] 任一輸入改變就重新計算本區塊；所有路徑都有賦值時不需要記憶狀態；更新 `frame`（動畫影格）為 0/關閉或初始值；更新 `color`為 0/關閉或初始值；更新 `show`，下一值由 `1`
// [逐行教學 L023][用途] 計算。
 always @(*) begin frame=0;color=0;show=1;
// [逐行教學 L024][語法] `if (!day_night)` 是條件分支：條件為 1 才執行後續敘述；`frame = ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`color =
// [逐行教學 L024][語法] ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`show = ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function。
// [逐行教學 L024][用途] 檢查 `!day_night` 以決定資料/狀態要走哪一條路徑；更新 `frame`（動畫影格），下一值由 `4` 計算；更新 `color`，下一值由 `2` 計算；更新 `show`，下一值由
// [逐行教學 L024][用途] `blink` 計算。
  if(!day_night) begin frame=4;color=2;show=blink;end
// [逐行教學 L025][語法] `if (mode==0)` 是條件分支：條件為 1 才執行後續敘述；`if (mode==1)` 是條件分支：條件為 1 才執行後續敘述；`if (mode==2)` 是條件分支：條件為 1
// [逐行教學 L025][語法] 才執行後續敘述；`else if` 只在前面 if 不成立時繼續測試下一個條件；`frame = ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`color =
// [逐行教學 L025][語法] ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`show = ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`end
// [逐行教學 L025][語法] else begin` 先結束前一分支，再開始 else 的多敘述分支；`==` 是相等比較，結果為 1 或 0。
// [逐行教學 L025][用途] 檢查 `mode==0` 以決定資料/狀態要走哪一條路徑；檢查 `mode==1` 以決定資料/狀態要走哪一條路徑；檢查 `mode==2` 以決定資料/狀態要走哪一條路徑；更新
// [逐行教學 L025][用途] `frame`（動畫影格），下一值由 `phase` 計算；更新 `color`為 0/關閉或初始值；更新 `show`，下一值由 `1` 計算；更新 `frame`（動畫影格），下一值由
// [逐行教學 L025][用途] `4+phase` 計算；更新 `frame`（動畫影格），下一值由 `4` 計算；更新 `color`，下一值由 `2` 計算；更新 `show`，下一值由 `blink` 計算；更新
// [逐行教學 L025][用途] `frame`（動畫影格）為 0/關閉或初始值；更新 `color`，下一值由 `1` 計算。
  else begin if(mode==0) begin frame=phase; color=0; show=1; end else if(mode==1) begin frame=4+phase; color=0; show=1; end else if(mode==2) begin frame=4; color=2; show=blink; end else begin frame=0;color=1;show=1;end end
// [逐行教學 L026][語法] `end` 結束最近一個 `begin` 區塊。
// [逐行教學 L026][用途] 關閉目前條件、時序或組合邏輯區塊。
 end
// [逐行教學 L027][語法] `pedestrian_rom_green UG(...)` 是子模組實例化；`UG` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port
// [逐行教學 L027][語法] mapping；`pedestrian_rom_red UR(...)` 是子模組實例化；`UR` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping。
// [逐行教學 L027][用途] 綠色行人動畫 ROM。；紅色行人停止圖樣 ROM。。
 pedestrian_rom_green UG(.frame(frame),.row(row_idx),.data(walkdata)); pedestrian_rom_red UR(.row(row_idx),.data(reddata));
// [逐行教學 L028][語法] `matrix_scan UMS(...)` 是子模組實例化；`UMS` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping；`1'b1` = 1-bit
// [逐行教學 L028][語法] 二進位常數。
// [逐行教學 L028][用途] 8×8 LED Matrix 掃描器。。
 matrix_scan UMS(.clk(clk_matrix),.reset(rst),.tick_scan(1'b1),.row_idx(row_idx),.row(matrix_row));
// [逐行教學 L029][語法] `always @(*)` 自動把區塊內讀到的訊號加入敏感度表，通常描述組合邏輯；同一行的 `begin` 開始一個多敘述區塊；`if (show)` 是條件分支：條件為 1 才執行後續敘述；`if
// [逐行教學 L029][語法] (color==0)` 是條件分支：條件為 1 才執行後續敘述；`if (color==1)` 是條件分支：條件為 1 才執行後續敘述；`else if` 只在前面 if
// [逐行教學 L029][語法] 不成立時繼續測試下一個條件；`else if(...)` 是子模組實例化；`if` 是這一顆硬體實例名稱；`matrix_red_col = ...`
// [逐行教學 L029][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`matrix_green_col = ...`
// [逐行教學 L029][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`==` 是相等比較，結果為 1 或 0。
// [逐行教學 L029][用途] 任一輸入改變就重新計算本區塊；所有路徑都有賦值時不需要記憶狀態；檢查 `show` 以決定資料/狀態要走哪一條路徑；檢查 `color==0` 以決定資料/狀態要走哪一條路徑；檢查
// [逐行教學 L029][用途] `color==1` 以決定資料/狀態要走哪一條路徑；把 `else` 子模組放進目前模組並與內部訊號連線；更新 `matrix_red_col`為 0/關閉或初始值；更新
// [逐行教學 L029][用途] `matrix_green_col`為 0/關閉或初始值；更新 `matrix_green_col`，下一值由 `walkdata` 計算；更新 `matrix_red_col`，下一值由
// [逐行教學 L029][用途] `reddata` 計算；更新 `matrix_red_col`，下一值由 `walkdata` 計算。
 always @(*) begin matrix_red_col=0;matrix_green_col=0;if(show) begin if(color==0)matrix_green_col=walkdata;else if(color==1)matrix_red_col=reddata;else begin matrix_red_col=walkdata;matrix_green_col=walkdata;end end end
// [逐行教學 L030][語法] `seg7_select USS(...)` 是子模組實例化；`USS` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping；`1'b1` = 1-bit
// [逐行教學 L030][語法] 二進位常數。
// [逐行教學 L030][用途] 七段顯示器位選掃描器：快速輪流選擇多位七段顯示器。。
 seg7_select USS(.clk(clk_seg),.reset(rst),.tick_scan(1'b1),.seg7_sel(seg7_sel));
// [逐行教學 L031][語法] `always @(*)` 自動把區塊內讀到的訊號加入敏感度表，通常描述組合邏輯；同一行的 `begin` 開始一個多敘述區塊。
// [逐行教學 L031][用途] 任一輸入改變就重新計算本區塊；所有路徑都有賦值時不需要記憶狀態。
 always @(*) begin
// [逐行教學 L032][語法] `if (!day_night)` 是條件分支：條件為 1 才執行後續敘述。
// [逐行教學 L032][用途] 檢查 `!day_night` 以決定資料/狀態要走哪一條路徑。
  if(!day_night) begin
// [逐行教學 L033][語法] `case(seg7_sel)` 是多路選擇語法，依選擇值匹配各個 `標籤:`。
// [逐行教學 L033][用途] 硬體上通常形成解碼器/MUX，用狀態、按鍵或索引選擇不同輸出。
   case(seg7_sel)
// [逐行教學 L034][語法] `3'b000` 是 case item 標籤；case 值匹配時執行冒號後動作；`digit = ...`
// [逐行教學 L034][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`3'b000` = 3-bit 二進位常數；`3'b001` = 3-bit 二進位常數；`4'hF` = 4-bit
// [逐行教學 L034][語法] 十六進位常數。
// [逐行教學 L034][用途] 定義這個選擇值對應的輸出或下一狀態；更新 `digit`（目前七段顯示數字），下一值由 `4'hF` 計算。
    3'b000,3'b001: digit=4'hF;
// [逐行教學 L035][語法] `default:` 是 case 沒有其他標籤匹配時使用的預設分支；`digit = ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`4'd0` =
// [逐行教學 L035][語法] 4-bit 十進位常數。
// [逐行教學 L035][用途] 提供未列舉情況的安全輸出/預設動作；更新 `digit`（目前七段顯示數字），下一值由 `4'd0` 計算。
    default: digit=4'd0;
// [逐行教學 L036][語法] `endcase` 結束前面的 case 多路選擇區塊。
// [逐行教學 L036][用途] 完成目前 case 解碼邏輯。
   endcase
// [逐行教學 L037][語法] `else` 是前面條件都不成立時執行的備援分支；`end else begin` 先結束前一分支，再開始 else 的多敘述分支。
// [逐行教學 L037][用途] 完成目前模組資料路徑或控制流程中的一個步驟。
  end else begin
// [逐行教學 L038][語法] `case(seg7_sel)` 是多路選擇語法，依選擇值匹配各個 `標籤:`。
// [逐行教學 L038][用途] 硬體上通常形成解碼器/MUX，用狀態、按鍵或索引選擇不同輸出。
   case(seg7_sel)
// [逐行教學 L039][語法] `3'b000` 是 case item 標籤；case 值匹配時執行冒號後動作；`digit = ...`
// [逐行教學 L039][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`3'b000` = 3-bit 二進位常數；`3'b001` = 3-bit 二進位常數；`4'hF` = 4-bit
// [逐行教學 L039][語法] 十六進位常數。
// [逐行教學 L039][用途] 定義這個選擇值對應的輸出或下一狀態；更新 `digit`（目前七段顯示數字），下一值由 `4'hF` 計算。
    3'b000,3'b001: digit=4'hF;
// [逐行教學 L040][語法] `3'b010` 是 case item 標籤；case 值匹配時執行冒號後動作；`digit = ...`
// [逐行教學 L040][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`3'b010` = 3-bit 二進位常數；`3'b011` = 3-bit 二進位常數；`4'd0` = 4-bit
// [逐行教學 L040][語法] 十進位常數。
// [逐行教學 L040][用途] 定義這個選擇值對應的輸出或下一狀態；更新 `digit`（目前七段顯示數字），下一值由 `4'd0` 計算。
    3'b010,3'b011: digit=4'd0;
// [逐行教學 L041][語法] `3'b100` 是 case item 標籤；case 值匹配時執行冒號後動作；`digit = ...`
// [逐行教學 L041][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function；`3'b100` = 3-bit 二進位常數。
// [逐行教學 L041][用途] 定義這個選擇值對應的輸出或下一狀態；更新 `digit`（目前七段顯示數字），下一值由 `red_count/10` 計算。
    3'b100: digit=red_count/10;
// [逐行教學 L042][語法] `default:` 是 case 沒有其他標籤匹配時使用的預設分支；`digit = ...` 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function。
// [逐行教學 L042][用途] 提供未列舉情況的安全輸出/預設動作；更新 `digit`（目前七段顯示數字），下一值由 `red_count-(red_count/10)*10` 計算。
    default: digit=red_count-(red_count/10)*10;
// [逐行教學 L043][語法] `endcase` 結束前面的 case 多路選擇區塊。
// [逐行教學 L043][用途] 完成目前 case 解碼邏輯。
   endcase
// [逐行教學 L044][語法] `end` 結束最近一個 `begin` 區塊。
// [逐行教學 L044][用途] 關閉目前條件、時序或組合邏輯區塊。
  end
// [逐行教學 L045][語法] `end` 結束最近一個 `begin` 區塊。
// [逐行教學 L045][用途] 關閉目前條件、時序或組合邏輯區塊。
 end
// [逐行教學 L046][語法] `bcd_to_seg7 USD(...)` 是子模組實例化；`USD` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping。
// [逐行教學 L046][用途] 七段顯示器解碼器：把 4-bit 數字/代碼轉成 a~g 七段亮滅資料。。
 bcd_to_seg7 USD(.bcd_in(digit),.seg7(seg7_out));
// [逐行教學 L047][語法] `endmodule` 與前面的 `module` 配對，結束模組定義。
// [逐行教學 L047][用途] 結束 `traffic_top` 的 RTL 描述。
endmodule
