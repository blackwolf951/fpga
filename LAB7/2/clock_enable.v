module clock_enable #(
    parameter CLK_FREQ_HZ = 8388608
)(
    input clk, input rst,
    output reg tick_1hz,
    output reg tick_2hz,
    output reg tick_256hz,
    output reg tick_2048hz
);

    reg [31:0] cnt_1hz, cnt_2hz, cnt_256hz, cnt_2048hz;

    localparam integer DIV_1HZ    = CLK_FREQ_HZ;
    localparam integer DIV_2HZ    = CLK_FREQ_HZ / 2;
    localparam integer DIV_256HZ  = CLK_FREQ_HZ / 256;
    localparam integer DIV_2048HZ = CLK_FREQ_HZ / 2048;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt_1hz <= 0; cnt_2hz <= 0; cnt_256hz <= 0; cnt_2048hz <= 0;
            tick_1hz <= 0; tick_2hz <= 0; tick_256hz <= 0; tick_2048hz <= 0;
        end else begin
            tick_1hz <= 0; tick_2hz <= 0; tick_256hz <= 0; tick_2048hz <= 0;

            if (cnt_1hz == DIV_1HZ-1) begin cnt_1hz <= 0; tick_1hz <= 1; end
            else cnt_1hz <= cnt_1hz + 1'b1;

            if (cnt_2hz == DIV_2HZ-1) begin cnt_2hz <= 0; tick_2hz <= 1; end
            else cnt_2hz <= cnt_2hz + 1'b1;

            if (cnt_256hz == DIV_256HZ-1) begin cnt_256hz <= 0; tick_256hz <= 1; end
            else cnt_256hz <= cnt_256hz + 1'b1;

            if (cnt_2048hz == DIV_2048HZ-1) begin cnt_2048hz <= 0; tick_2048hz <= 1; end
            else cnt_2048hz <= cnt_2048hz + 1'b1;
        end
    end
endmodule
