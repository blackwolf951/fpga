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
