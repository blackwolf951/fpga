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
