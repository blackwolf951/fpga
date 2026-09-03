FPGA 期中考逐行教學版
======================

所有 109 個 .v 檔案：每一個原始實體行前都有 [語法] 與 [用途]。
原始 Verilog 行沒有改寫，只新增 // 註解。
.qsf / .qpf / 原題 PDF 保留原檔，方便 Quartus 專案繼續使用。

vscode.dev 若把中文框黃框：
Settings JSON 加入：
"editor.unicodeHighlight.nonBasicASCII": false

建議閱讀順序：module I/O -> wire/reg -> assign/子模組 -> always @(*) -> always @(posedge...) -> endmodule
