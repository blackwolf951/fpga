module bcd_led(key_code, led);
    input [3:0] key_code;
    output [9:0] led;
    reg [9:0] led;

    always @(key_code) begin
        case(key_code)
            4'b0000: led = 10'b0000000001;  // 0
            4'b0001: led = 10'b0000000010;  // 1
            4'b0010: led = 10'b0000000100;  // 2
            4'b0011: led = 10'b0000001000;  // 3
            4'b0100: led = 10'b0000010000;  // 4
            4'b0101: led = 10'b0000100000;  // 5
            4'b0110: led = 10'b0001000000;  // 6
            4'b0111: led = 10'b0010000000;  // 7
            4'b1000: led = 10'b0100000000;  // 8
            4'b1001: led = 10'b1000000000;  // 9
            default: led = 10'b0000000000;  // 關閉所有燈[cite: 7]
        endcase
    end
endmodule
