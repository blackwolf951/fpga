module blink_gen(
    input clk, input rst, input tick_1hz,
    output reg blink
);
    always @(posedge clk or posedge rst) begin
        if (rst) blink <= 1'b0;
        else if (tick_1hz) blink <= ~blink;
    end
endmodule
