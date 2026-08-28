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
