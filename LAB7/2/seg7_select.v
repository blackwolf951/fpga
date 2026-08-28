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
