module frame_gen(
    input clk,
    input rst,
    input tick_scan,

    input [3:0] frame_idx,
    input       color_sel,
    input       day_night,

    output reg [7:0] matrix_row,
    output reg [7:0] matrix_red_col,
    output reg [7:0] matrix_green_col
);

    // =========================================================
    // 8x8 LED Matrix
    //
    // 使用你「正常能跑動畫」版本的掃描方式
    //
    // Row:
    //   10000000
    //   01000000
    //   00100000
    //   00010000
    //   00001000
    //   00000100
    //   00000010
    //   00000001
    //
    // =========================================================

    reg [2:0] row_idx;

    wire [7:0] green_data;
    wire [7:0] red_data;


    // =========================================================
    // Row counter
    // =========================================================

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            row_idx <= 3'd0;

        end

        else if (tick_scan) begin

            row_idx <= row_idx + 3'd1;

        end

    end


    // =========================================================
    // ROM
    // =========================================================

    pedestrian_rom_green U_GREEN (
        .frame(frame_idx),
        .row(row_idx),
        .data(green_data)
    );


    pedestrian_rom_red U_RED (
        .row(row_idx),
        .data(red_data)
    );


    // =========================================================
    // Row output
    // ACTIVE HIGH
    // =========================================================

    always @(*) begin

        matrix_row = 8'b0;

        case (row_idx)

            3'd0: matrix_row = 8'b1000_0000;
            3'd1: matrix_row = 8'b0100_0000;
            3'd2: matrix_row = 8'b0010_0000;
            3'd3: matrix_row = 8'b0001_0000;
            3'd4: matrix_row = 8'b0000_1000;
            3'd5: matrix_row = 8'b0000_0100;
            3'd6: matrix_row = 8'b0000_0010;
            3'd7: matrix_row = 8'b0000_0001;

            default:
                matrix_row = 8'b0;

        endcase

    end


    // =========================================================
    // Column output
    // =========================================================

    always @(*) begin

        // 夜間：全部關閉
        if (!day_night) begin

            matrix_green_col = 8'h00;
            matrix_red_col   = 8'h00;

        end

        // 紅色小人
        else if (color_sel) begin

            matrix_green_col = 8'h00;
            matrix_red_col   = red_data;

        end

        // 綠色小人
        else begin

            matrix_green_col = green_data;
            matrix_red_col   = 8'h00;

        end

    end

endmodule