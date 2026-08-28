// ============================================================
// Lab 7 - Traffic Light + 8x8 Pedestrian Signal
// Single master-clock architecture
//
// Original lab divider set:
//   freq_div#(23) -> 1 Hz
//   freq_div#(21) -> 4 Hz
//   freq_div#(15) -> 256 Hz
//
// Therefore CLK_FREQ_HZ = 8,388,608 Hz.
// If your board clock is different, change CLK_FREQ_HZ.
// ============================================================

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


module blink_gen(
    input clk, input rst, input tick_1hz,
    output reg blink
);
    always @(posedge clk or posedge rst) begin
        if (rst) blink <= 1'b0;
        else if (tick_1hz) blink <= ~blink;
    end
endmodule


module traffic_core(
    input clk, input rst, input tick_1hz, input blink_1hz, input day_night,
    output reg [2:0] mode,
    output reg [7:0] g1_cnt,
    output reg [7:0] g2_cnt,
    output reg [5:0] light_led
);

    function [7:0] dec_bcd;
        input [7:0] value;
        begin
            if (value == 8'h00)
                dec_bcd = 8'h29;
            else if (value[3:0] == 4'd0)
                dec_bcd = {value[7:4] - 1'b1, 4'd9};
            else
                dec_bcd = value - 1'b1;
        end
    endfunction

    always @(*) begin
        if (!day_night)
            light_led = {1'b0, blink_1hz, 1'b0, 1'b0, blink_1hz, 1'b0};
        else begin
            case (mode)
                3'd0: light_led = 6'b001100;
                3'd1: light_led = {2'b00, blink_1hz, 1'b1, 2'b00};
                3'd2: light_led = 6'b010100;
                3'd3: light_led = 6'b100001;
                3'd4: light_led = {1'b1, 4'b0000, blink_1hz};
                3'd5: light_led = 6'b100010;
                default: light_led = 6'b001100;
            endcase
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode <= 3'd0;
            g1_cnt <= 8'h00;
            g2_cnt <= 8'h00;
        end else if (tick_1hz) begin
            if (!day_night) begin
                mode <= 3'd0;
                g1_cnt <= 8'h00;
                g2_cnt <= 8'h00;
            end else begin
                case (mode)
                    3'd0: begin
                        g2_cnt <= 8'h00;
                        if (g1_cnt == 8'h00) g1_cnt <= 8'h29;
                        else g1_cnt <= dec_bcd(g1_cnt);
                        if (g1_cnt == 8'h10) mode <= 3'd1; // 10->09
                    end

                    3'd1: begin
                        if (g1_cnt == 8'h00) g1_cnt <= 8'h29;
                        else g1_cnt <= dec_bcd(g1_cnt);
                        if (g1_cnt == 8'h05) mode <= 3'd2; // 05->04
                    end

                    3'd2: begin
                        if (g1_cnt != 8'h00) g1_cnt <= dec_bcd(g1_cnt);
                        if (g1_cnt == 8'h01) begin // 01->00
                            mode <= 3'd3;
                            g1_cnt <= 8'h00;
                            g2_cnt <= 8'h29;
                        end
                    end

                    3'd3: begin
                        g1_cnt <= 8'h00;
                        if (g2_cnt == 8'h00) g2_cnt <= 8'h29;
                        else g2_cnt <= dec_bcd(g2_cnt);
                        if (g2_cnt == 8'h10) mode <= 3'd4; // 10->09
                    end

                    3'd4: begin
                        if (g2_cnt == 8'h00) g2_cnt <= 8'h29;
                        else g2_cnt <= dec_bcd(g2_cnt);
                        if (g2_cnt == 8'h05) mode <= 3'd5; // 05->04
                    end

                    3'd5: begin
                        if (g2_cnt != 8'h00) g2_cnt <= dec_bcd(g2_cnt);
                        if (g2_cnt == 8'h01) begin // 01->00
                            mode <= 3'd0;
                            g2_cnt <= 8'h00;
                            g1_cnt <= 8'h29;
                        end
                    end

                    default: begin
                        mode <= 3'd0;
                        g1_cnt <= 8'h00;
                        g2_cnt <= 8'h00;
                    end
                endcase
            end
        end
    end
endmodule


module pedestrian_controller(
    input clk, input rst, input tick_2hz,
    input day_night, input [2:0] mode,
    output reg [3:0] frame_idx,
    output reg color_sel
);

    reg [1:0] frame_phase;

    always @(posedge clk or posedge rst) begin
        if (rst) frame_phase <= 2'd0;
        else if (tick_2hz) begin
            if (day_night && (mode == 3'd0 || mode == 3'd1))
                frame_phase <= frame_phase + 1'b1;
            else
                frame_phase <= 2'd0;
        end
    end

    always @(*) begin
        if (!day_night) begin
            color_sel = 1'b0;
            frame_idx = 4'd0;
        end else begin
            case (mode)
                3'd0: begin
                    color_sel = 1'b0;
                    frame_idx = {2'b00, frame_phase};       // 0~3
                end
                3'd1: begin
                    color_sel = 1'b0;
                    frame_idx = 4'd4 + {2'b00, frame_phase}; // 4~7
                end
                default: begin
                    color_sel = 1'b1;
                    frame_idx = 4'd0;
                end
            endcase
        end
    end
endmodule


module pedestrian_rom_green(
    input [3:0] frame, input [2:0] row,
    output reg [7:0] data
);
    always @(*) begin
        case ({frame,row})
            7'd0 : data = 8'h0A;  7'd1 : data = 8'h04;
            7'd2 : data = 8'h04;  7'd3 : data = 8'h1F;
            7'd4 : data = 8'h04;  7'd5 : data = 8'h0E;
            7'd6 : data = 8'h0E;  7'd7 : data = 8'h0E;

            7'd8 : data = 8'h14;  7'd9 : data = 8'h08;
            7'd10: data = 8'h08;  7'd11: data = 8'h3E;
            7'd12: data = 8'h08;  7'd13: data = 8'h1C;
            7'd14: data = 8'h1C;  7'd15: data = 8'h1C;

            7'd16: data = 8'h28;  7'd17: data = 8'h10;
            7'd18: data = 8'h10;  7'd19: data = 8'h7C;
            7'd20: data = 8'h10;  7'd21: data = 8'h38;
            7'd22: data = 8'h38;  7'd23: data = 8'h38;

            7'd24: data = 8'h50;  7'd25: data = 8'h20;
            7'd26: data = 8'h20;  7'd27: data = 8'hF8;
            7'd28: data = 8'h20;  7'd29: data = 8'h70;
            7'd30: data = 8'h70;  7'd31: data = 8'h70;

            7'd32: data = 8'h14;  7'd33: data = 8'h08;
            7'd34: data = 8'h1C;  7'd35: data = 8'h2A;
            7'd36: data = 8'h08;  7'd37: data = 8'h1C;
            7'd38: data = 8'h1C;  7'd39: data = 8'h1C;

            7'd40: data = 8'h28;  7'd41: data = 8'h10;
            7'd42: data = 8'h38;  7'd43: data = 8'h54;
            7'd44: data = 8'h10;  7'd45: data = 8'h38;
            7'd46: data = 8'h38;  7'd47: data = 8'h38;

            7'd48: data = 8'h28;  7'd49: data = 8'h10;
            7'd50: data = 8'h10;  7'd51: data = 8'h7C;
            7'd52: data = 8'h10;  7'd53: data = 8'h38;
            7'd54: data = 8'h38;  7'd55: data = 8'h38;

            7'd56: data = 8'h50;  7'd57: data = 8'h20;
            7'd58: data = 8'h20;  7'd59: data = 8'hF8;
            7'd60: data = 8'h20;  7'd61: data = 8'h70;
            7'd62: data = 8'h70;  7'd63: data = 8'h70;

            default: data = 8'h00;
        endcase
    end
endmodule


module pedestrian_rom_red(
    input [2:0] row,
    output reg [7:0] data
);
    always @(*) begin
        case (row)
            3'd0: data = 8'h0A;
            3'd1: data = 8'h04;
            3'd2: data = 8'h04;
            3'd3: data = 8'h1F;
            3'd4: data = 8'h04;
            3'd5: data = 8'h0E;
            3'd6: data = 8'h0E;
            3'd7: data = 8'h0E;
            default: data = 8'h00;
        endcase
    end
endmodule


module frame_gen(
    input clk, input rst, input tick_scan,
    input [3:0] frame_idx, input color_sel, input day_night,
    output reg [7:0] matrix_row,
    output reg [7:0] matrix_red_col,
    output reg [7:0] matrix_green_col
);

    reg [2:0] row_idx;
    wire [7:0] green_data;
    wire [7:0] red_data;

    always @(posedge clk or posedge rst) begin
        if (rst) row_idx <= 3'd0;
        else if (tick_scan) row_idx <= row_idx + 1'b1;
    end

    pedestrian_rom_green U_GREEN (
        .frame(frame_idx), .row(row_idx), .data(green_data)
    );

    pedestrian_rom_red U_RED (
        .row(row_idx), .data(red_data)
    );

    always @(*) begin
        case (row_idx)
            3'd0: matrix_row = 8'b11111110;
            3'd1: matrix_row = 8'b11111101;
            3'd2: matrix_row = 8'b11111011;
            3'd3: matrix_row = 8'b11110111;
            3'd4: matrix_row = 8'b11101111;
            3'd5: matrix_row = 8'b11011111;
            3'd6: matrix_row = 8'b10111111;
            3'd7: matrix_row = 8'b01111111;
            default: matrix_row = 8'b11111111;
        endcase

        if (!day_night) begin
            matrix_red_col = 8'h00;
            matrix_green_col = 8'h00;
        end else if (color_sel) begin
            matrix_red_col = red_data;
            matrix_green_col = 8'h00;
        end else begin
            matrix_red_col = 8'h00;
            matrix_green_col = green_data;
        end
    end
endmodule


module seg7_select #(
    parameter num_use = 6
)(
    input clk, input reset, input tick_scan,
    output reg [2:0] seg7_sel
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            seg7_sel <= 3'b101;
        else if (tick_scan) begin
            if (seg7_sel == (6 - num_use))
                seg7_sel <= 3'b101;
            else
                seg7_sel <= seg7_sel - 3'b001;
        end
    end
endmodule


module bcd_to_seg7(
    input [3:0] bcd_in,
    output reg [6:0] seg7
);
    always @(*) begin
        case (bcd_in)
            4'd0: seg7 = 7'b1111110;
            4'd1: seg7 = 7'b0110000;
            4'd2: seg7 = 7'b1101101;
            4'd3: seg7 = 7'b1111001;
            4'd4: seg7 = 7'b0110011;
            4'd5: seg7 = 7'b1011011;
            4'd6: seg7 = 7'b1011111;
            4'd7: seg7 = 7'b1110000;
            4'd8: seg7 = 7'b1111111;
            4'd9: seg7 = 7'b1111011;
            default: seg7 = 7'b0000000;
        endcase
    end
endmodule
