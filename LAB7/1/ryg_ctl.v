module ryg_ctl (
    clk_fst, clk_cnt_dn, rst, day_night, g1_cnt, g2_cnt, g1_en, g2_en, light_led, mode_out
);
    input        clk_fst, clk_cnt_dn, rst, day_night;
    input  [7:0] g1_cnt, g2_cnt;
    output       g1_en, g2_en;
    output [5:0] light_led;   // {L1, L2, L3, L4, L5, L6}
    output [2:0] mode_out;

    reg g1_en, g2_en;
    reg [5:0] light_led;
    reg [2:0] mode;

    assign mode_out = mode;

    always @(posedge clk_fst or posedge rst) begin
        if (rst) begin
            light_led <= 6'b001_100;     // L3(G1)亮, L4(R2)亮
            mode      <= 3'b000;
            g1_en     <= 1'b0;
            g2_en     <= 1'b0;
        end
        else if (day_night == 1'b1) begin      
            case (mode)
                // Mode 0: 綠燈1亮 (L3)，紅燈2亮 (L4)
                3'd0: begin
                    light_led <= 6'b001_100; // {0, 0, 1, 1, 0, 0}
                    g1_en <= 1'b1;
                    g2_en <= 1'b0;
                    if (g1_cnt == 8'b0000_1001) mode <= mode + 3'b1;
                end
                
                // Mode 1: 綠燈1閃爍 (L3)，紅燈2亮 (L4)
                3'd1: begin
                    g1_en <= 1'b1;
                    g2_en <= 1'b0;
                    if (g1_cnt == 8'b0000_0100) mode <= mode + 3'b1;
                    else light_led <= {2'b00, clk_cnt_dn, 1'b1, 2'b00}; 
                end
                
                // Mode 2: 黃燈1亮 (L2)，紅燈2亮 (L4)
                3'd2: begin
                    light_led <= 6'b010_100; // {0, 1, 0, 1, 0, 0}
                    g1_en <= 1'b1;
                    g2_en <= 1'b0;
                    if (g1_cnt == 8'b0000_0000) begin
                        g1_en <= 1'b0;
                        mode  <= mode + 3'b1;
                    end
                end
                
                // Mode 3: 紅燈1亮 (L1)，綠燈2亮 (L6)
                3'd3: begin
                    light_led <= 6'b100_001; // {1, 0, 0, 0, 0, 1}
                    g1_en <= 1'b0;
                    g2_en <= 1'b1;
                    if (g2_cnt == 8'b0000_1001) mode <= mode + 3'b1;
                end
                
                // Mode 4: 紅燈1亮 (L1)，綠燈2閃爍 (L6)
                3'd4: begin
                    g1_en <= 1'b0;
                    g2_en <= 1'b1;
                    if (g2_cnt == 8'b0000_0100) mode <= mode + 3'b1;
                    else light_led <= {1'b1, 4'b0000, clk_cnt_dn}; 
                end
                
                // Mode 5: 紅燈1亮 (L1)，黃燈2亮 (L5)
                3'd5: begin
                    light_led <= 6'b100_010; // {1, 0, 0, 0, 1, 0}
                    g1_en <= 1'b0;
                    g2_en <= 1'b1;
                    if (g2_cnt == 8'b0000_0000) begin
                        g2_en <= 1'b0;
                        mode <= 3'b000;
                    end
                end
                
                // 預防錯誤機制
                default: begin
                    light_led <= 6'b001_100;
                    g1_en <= 1'b1;
                    g2_en <= 1'b0;
                    mode <= 3'b000;
                end
            endcase
        end
        else begin // 夜晚模式: 黃燈1閃爍 (L2)、黃燈2閃爍 (L5)
            light_led <= {1'b0, clk_cnt_dn, 2'b00, clk_cnt_dn, 1'b0};
            g1_en <= 1'b0;
            g2_en <= 1'b0;
            mode  <= 3'b000;
        end
    end
endmodule