module traffic_top #(
    parameter CLK_FREQ_HZ = 8388608
)(
    input         clk,
    input         rst,
    input         day_night,
    output [11:0] light_led,
    output        led_com,
    output [6:0]  seg7_out,
    output [2:0]  seg7_sel,
    output [7:0]  matrix_row,
    output [7:0]  matrix_red_col,
    output [7:0]  matrix_green_col
);

    wire tick_1hz, tick_2hz, tick_256hz, tick_2048hz;
    wire blink_1hz;
    wire [2:0] mode;
    wire [7:0] g1_cnt, g2_cnt;
    wire [5:0] internal_light;
    wire [3:0] ped_frame;
    wire ped_color_red;
    reg [3:0] count_out;

    assign led_com   = 1'b1;
    assign light_led = {6'b000000, internal_light};

    clock_enable #(.CLK_FREQ_HZ(CLK_FREQ_HZ)) U_CLK (
        .clk(clk), .rst(rst),
        .tick_1hz(tick_1hz),
        .tick_2hz(tick_2hz),
        .tick_256hz(tick_256hz),
        .tick_2048hz(tick_2048hz)
    );

    blink_gen U_BLINK (
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz), .blink(blink_1hz)
    );

    traffic_core U_TRAFFIC (
        .clk(clk), .rst(rst), .tick_1hz(tick_1hz),
        .blink_1hz(blink_1hz), .day_night(day_night),
        .mode(mode), .g1_cnt(g1_cnt), .g2_cnt(g2_cnt),
        .light_led(internal_light)
    );

    pedestrian_controller U_PED (
        .clk(clk), .rst(rst), .tick_2hz(tick_2hz),
        .day_night(day_night), .mode(mode),
        .frame_idx(ped_frame), .color_sel(ped_color_red)
    );

    frame_gen U_MATRIX (
        .clk(clk), .rst(rst), .tick_scan(tick_2048hz),
        .frame_idx(ped_frame), .color_sel(ped_color_red),
        .day_night(day_night),
        .matrix_row(matrix_row),
        .matrix_red_col(matrix_red_col),
        .matrix_green_col(matrix_green_col)
    );

    seg7_select #(.num_use(6)) U_SEGSEL (
        .clk(clk), .reset(rst), .tick_scan(tick_256hz), .seg7_sel(seg7_sel)
    );

    // Mode 0/1: G1 countdown
    // Mode 3/4: G2 countdown
    // Mode 2/5 and night: 0
    always @(*) begin
        count_out = 4'd0;
        if (day_night) begin
            case (mode)
                3'd0, 3'd1: begin
                    case (seg7_sel)
                        3'b101: count_out = g1_cnt[3:0];
                        3'b100: count_out = g1_cnt[7:4];
                        default: count_out = 4'd0;
                    endcase
                end
                3'd3, 3'd4: begin
                    case (seg7_sel)
                        3'b101: count_out = g2_cnt[3:0];
                        3'b100: count_out = g2_cnt[7:4];
                        default: count_out = 4'd0;
                    endcase
                end
                default: count_out = 4'd0;
            endcase
        end
    end

    bcd_to_seg7 U_SEGDEC (.bcd_in(count_out), .seg7(seg7_out));

endmodule
