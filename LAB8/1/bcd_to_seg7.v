module bcd_to_seg7(bcd_in, seg7);
    input [3:0] bcd_in;
    output [6:0] seg7;
    reg [6:0] seg7;
    
    always @(bcd_in) begin
        case(bcd_in) // abcdefg
            4'b0000: seg7 = 7'b1111110; // 0[cite: 9]
            4'b0001: seg7 = 7'b0110000; // 1[cite: 9]
            4'b0010: seg7 = 7'b1101101; // 2[cite: 9]
            4'b0011: seg7 = 7'b1111001; // 3[cite: 9]
            4'b0100: seg7 = 7'b0110011; // 4[cite: 9]
            4'b0101: seg7 = 7'b1011011; // 5[cite: 9]
            4'b0110: seg7 = 7'b1011111; // 6[cite: 9]
            4'b0111: seg7 = 7'b1110000; // 7[cite: 9]
            4'b1000: seg7 = 7'b1111111; // 8[cite: 9]
            4'b1001: seg7 = 7'b1111011; // 9[cite: 9]
            default: seg7 = 7'b0000000; //[cite: 9]
        endcase
    end
endmodule