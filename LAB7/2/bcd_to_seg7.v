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
