// ============================================================================
// [教學註解] 檔案：clock_enable.v
// [教學註解] 模組：clock_enable
// [教學註解] 功能：時脈使能產生器：以計數器產生週期性單脈波 tick，避免直接建立額外慢時脈。
// [教學註解] 閱讀方式：先看 I/O → 再看組合邏輯(assign/always @*) → 最後看時序邏輯(posedge)。
// [教學註解] 本次僅新增說明註解，不修改原本 Verilog 程式敘述與接線。
// ============================================================================
module clock_enable #(
    // [教學註解] 參數(parameter)：讓常數可以在實例化時調整，用來控制位寬、分頻比或狀態設定。
    parameter CLK_FREQ_HZ = 8388608
)(
    input clk, input rst,
    output reg tick_1hz,
    output reg tick_2hz,
    output reg tick_256hz,
    output reg tick_2048hz
);

    // [教學註解] 程序賦值暫存型訊號(reg)：宣告此區塊中使用的訊號與位元寬度。
    reg [31:0] cnt_1hz, cnt_2hz, cnt_256hz, cnt_2048hz;

    // [教學註解] 參數(parameter)：讓常數可以在實例化時調整，用來控制位寬、分頻比或狀態設定。
    localparam integer DIV_1HZ    = CLK_FREQ_HZ;
    // [教學註解] 參數(parameter)：讓常數可以在實例化時調整，用來控制位寬、分頻比或狀態設定。
    localparam integer DIV_2HZ    = CLK_FREQ_HZ / 2;
    // [教學註解] 參數(parameter)：讓常數可以在實例化時調整，用來控制位寬、分頻比或狀態設定。
    localparam integer DIV_256HZ  = CLK_FREQ_HZ / 256;
    // [教學註解] 參數(parameter)：讓常數可以在實例化時調整，用來控制位寬、分頻比或狀態設定。
    localparam integer DIV_2048HZ = CLK_FREQ_HZ / 2048;

    // [教學註解] 時序邏輯：在時脈邊緣更新狀態；reset/rst 也列在敏感度表中，所以是非同步重置。
    always @(posedge clk or posedge rst) begin
        // [教學註解] 重置判斷：重置成立時先把暫存器帶回已知初始狀態，避免上電後狀態不確定。
        if (rst) begin
            cnt_1hz <= 0; cnt_2hz <= 0; cnt_256hz <= 0; cnt_2048hz <= 0;
            tick_1hz <= 0; tick_2hz <= 0; tick_256hz <= 0; tick_2048hz <= 0;
        end else begin
            tick_1hz <= 0; tick_2hz <= 0; tick_256hz <= 0; tick_2048hz <= 0;

            if (cnt_1hz == DIV_1HZ-1) begin cnt_1hz <= 0; tick_1hz <= 1; end
            // [教學註解] 計數 +1：每次有效時脈事件讓目前數值增加一。
            else cnt_1hz <= cnt_1hz + 1'b1;

            if (cnt_2hz == DIV_2HZ-1) begin cnt_2hz <= 0; tick_2hz <= 1; end
            // [教學註解] 計數 +1：每次有效時脈事件讓目前數值增加一。
            else cnt_2hz <= cnt_2hz + 1'b1;

            if (cnt_256hz == DIV_256HZ-1) begin cnt_256hz <= 0; tick_256hz <= 1; end
            // [教學註解] 計數 +1：每次有效時脈事件讓目前數值增加一。
            else cnt_256hz <= cnt_256hz + 1'b1;

            if (cnt_2048hz == DIV_2048HZ-1) begin cnt_2048hz <= 0; tick_2048hz <= 1; end
            // [教學註解] 計數 +1：每次有效時脈事件讓目前數值增加一。
            else cnt_2048hz <= cnt_2048hz + 1'b1;
        end
    end
endmodule
