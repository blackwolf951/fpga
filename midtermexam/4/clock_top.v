// [逐行教學 HEADER] ===============================================================
// [逐行教學 HEADER] 檔案：clock_top.v
// [逐行教學 HEADER] 主要模組：clock_top
// [逐行教學 HEADER] 整體用途：計時器頂層：整合分頻、計數、位選與七段解碼。
// [逐行教學 HEADER] 每一個「原始實體行」前都加入 [語法] + [用途]，原始程式行本身不修改。
// [逐行教學 HEADER] 若一個原始行塞了多個敘述，註解會把同一行內的宣告/賦值/子模組一起拆解說明。
// [逐行教學 HEADER] ===============================================================
// [逐行教學 L001][語法] `module` 宣告一個硬體模組；模組名稱後括號列出對外 I/O；埠列表直接出現 `input/output`，屬 ANSI-style 埠宣告。
// [逐行教學 L001][用途] 計時器頂層：整合分頻、計數、位選與七段解碼。。
module clock_top(input clk,input reset,input enable,
// [逐行教學 L002][語法] `output` 宣告由模組送到外部的輸出埠；`[2:0]` 指定位元範圍。
// [逐行教學 L002][用途] 本段宣告：seg7_sel=七段位選；seg7_out=七段段碼。
 output [2:0] seg7_sel,output [6:0] seg7_out,output dpt_out,output led_com);
// [逐行教學 L003][語法] `wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`wire` 宣告連線型訊號，通常由 `assign` 或子模組輸出驅動；`[3:0]` 指定位元範圍；`reg` 宣告可在
// [逐行教學 L003][語法] `always/function` 中賦值的程序變數；是否形成 DFF 由 always 類型決定；`[3:0]` 指定位元範圍。
// [逐行教學 L003][用途] 本段宣告：clk_1hz, clk_scan；本段宣告：a, bt, bo, ch, ct, co；本段宣告：digit=目前七段顯示數字。
 wire clk_1hz,clk_scan; wire [3:0] a,bt,bo,ch,ct,co; reg [3:0] digit;
// [逐行教學 L004][語法] `assign 左式 = 右式;` 是 continuous assignment；這裡的 `=` 屬連續指定，不是 always 內的阻塞賦值；`1'b1` = 1-bit 二進位常數。
// [逐行教學 L004][用途] 更新 `led_com`，下一值由 `1'b1` 計算；右式一變化就立即重新驅動左側 wire。
 assign led_com=1'b1;
// [逐行教學 L005][語法] `freq_div_1s U_1S(...)` 是子模組實例化；`U_1S` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping。
// [逐行教學 L005][用途] 1 秒時基產生器：把系統時脈轉成約 1 Hz 的秒節拍。。
 freq_div_1s U_1S(.clk_in(clk),.reset(reset),.clk_out(clk_1hz));
// [逐行教學 L006][語法] `freq_div U_SCAN(...)` 是子模組實例化；`U_SCAN` 是這一顆硬體實例名稱；`#(12)` 是 parameter
// [逐行教學 L006][語法] override，用新值取代子模組預設參數；`.port(signal)` 是具名 port mapping。
// [逐行教學 L006][用途] 時脈分頻器：利用二進位計數器的某一位，把 FPGA 高速系統時脈降成較慢時脈。。
 freq_div #(12) U_SCAN(.clk_in(clk),.reset(reset),.clk_out(clk_scan));
// [逐行教學 L007][語法] `clock UC(...)` 是子模組實例化；`UC` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping；`1'b1` = 1-bit 二進位常數。
// [逐行教學 L007][用途] 計時/倒數核心：依時脈更新數字資料。。
 clock UC(.clk(clk_1hz),.reset(reset),.tick_1hz(1'b1),.enable(enable),.a(a),.bt(bt),.bo(bo),.ch(ch),.ct(ct),.co(co));
// [逐行教學 L008][語法] `seg7_select USEL(...)` 是子模組實例化；`USEL` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping；`1'b1` = 1-bit
// [逐行教學 L008][語法] 二進位常數。
// [逐行教學 L008][用途] 七段顯示器位選掃描器：快速輪流選擇多位七段顯示器。。
 seg7_select USEL(.clk(clk_scan),.reset(reset),.tick_scan(1'b1),.seg7_sel(seg7_sel));
// [逐行教學 L009][語法] `//` 是 Verilog 單行註解；從 `//` 到行尾不參與模擬邏輯或硬體綜合。
// [逐行教學 L009][用途] 保留原作者對題目、接線、狀態或設計意圖的文字說明。
 // left->right: A | BT BO | CH CT CO
// [逐行教學 L010][語法] `always @(*)` 自動把區塊內讀到的訊號加入敏感度表，通常描述組合邏輯；同一行的 `begin` 開始一個多敘述區塊；`case(seg7_sel)` 是多路選擇語法，依選擇值匹配各個
// [逐行教學 L010][語法] `標籤:`；`endcase` 結束前面的 case 多路選擇區塊；`default:` 是 case 沒有其他標籤匹配時使用的預設分支；`digit = ...`
// [逐行教學 L010][語法] 使用阻塞賦值；在程序區塊內依順序立即更新，常用於組合計算/function。
// [逐行教學 L010][用途] 任一輸入改變就重新計算本區塊；所有路徑都有賦值時不需要記憶狀態；硬體上通常形成解碼器/MUX，用狀態、按鍵或索引選擇不同輸出；完成目前 case 解碼邏輯；提供未列舉情況的安全輸出/預設動作；更新
// [逐行教學 L010][用途] `digit`（目前七段顯示數字），下一值由 `a` 計算；更新 `digit`（目前七段顯示數字），下一值由 `bt` 計算；更新 `digit`（目前七段顯示數字），下一值由 `bo` 計算；更新
// [逐行教學 L010][用途] `digit`（目前七段顯示數字），下一值由 `ch` 計算；更新 `digit`（目前七段顯示數字），下一值由 `ct` 計算；更新 `digit`（目前七段顯示數字），下一值由 `co` 計算。
 always @(*) begin case(seg7_sel) 0:digit=a;1:digit=bt;2:digit=bo;3:digit=ch;4:digit=ct;default:digit=co;endcase end
// [逐行教學 L011][語法] `assign 左式 = 右式;` 是 continuous assignment；這裡的 `=` 屬連續指定，不是 always 內的阻塞賦值；`3'b000` = 3-bit
// [逐行教學 L011][語法] 二進位常數；`3'b010` = 3-bit 二進位常數；`==` 是相等比較，結果為 1 或 0；`||` 是邏輯 OR：任一條件成立即為真。
// [逐行教學 L011][用途] 更新 `dpt_out`，下一值由 `(seg7_sel==3'b000 || seg7_sel==3'b010)` 計算；右式一變化就立即重新驅動左側 wire。
 assign dpt_out=(seg7_sel==3'b000 || seg7_sel==3'b010);
// [逐行教學 L012][語法] `bcd_to_seg7 UD(...)` 是子模組實例化；`UD` 是這一顆硬體實例名稱；`.port(signal)` 是具名 port mapping。
// [逐行教學 L012][用途] 七段顯示器解碼器：把 4-bit 數字/代碼轉成 a~g 七段亮滅資料。。
 bcd_to_seg7 UD(.bcd_in(digit),.seg7(seg7_out));
// [逐行教學 L013][語法] `endmodule` 與前面的 `module` 配對，結束模組定義。
// [逐行教學 L013][用途] 結束 `clock_top` 的 RTL 描述。
endmodule
