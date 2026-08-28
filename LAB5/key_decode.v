module key_decode(sel, column, press, scan_code);
    input [2:0] sel;
    input [2:0] column;
    output press;
    output [3:0] scan_code;
    
    reg [3:0] scan_code;
    reg press;

    always @(sel or column) begin
        case(sel)
            3'b000:
                case(column)
                    // 原本 011 是 1，若要往旁邊移，改對應實際按下的 column 狀態
                    3'b011: begin scan_code = 4'b0000; press = 1'b1; end // 依實際情況微調
                    3'b101: begin scan_code = 4'b0001; press = 1'b1; end // 按 1 顯示 1
                    3'b110: begin scan_code = 4'b0010; press = 1'b1; end // 按 2 顯示 2
                    default: begin scan_code = 4'b1111; press = 1'b0; end
                endcase
            3'b001:
                case(column)
                    3'b011: begin scan_code = 4'b0011; press = 1'b1; end 
                    3'b101: begin scan_code = 4'b0100; press = 1'b1; end 
                    3'b110: begin scan_code = 4'b0101; press = 1'b1; end 
                    default: begin scan_code = 4'b1111; press = 1'b0; end 
                endcase
            3'b010:
                case(column)
                    3'b011: begin scan_code = 4'b0110; press = 1'b1; end 
                    3'b101: begin scan_code = 4'b0111; press = 1'b1; end 
                    3'b110: begin scan_code = 4'b1000; press = 1'b1; end 
                    default: begin scan_code = 4'b1111; press = 1'b0; end 
                endcase
            3'b011:
                case(column)
                    3'b101: begin scan_code = 4'b1001; press = 1'b1; end 
                    default: begin scan_code = 4'b1111; press = 1'b0; end 
                endcase
            default: begin 
                scan_code = 4'b1111; press = 1'b0; 
            end
        endcase
    end
endmodule