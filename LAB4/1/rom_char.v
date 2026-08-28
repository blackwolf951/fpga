module rom_char(addr, data);
    input [6:0] addr;
    output [7:0] data;
    reg [7:0] data;
    
    always @(addr) begin
        case(addr)
        7'd0: data = 8'h00; 7'd1: data = 8'h00; // Blank
        7'd2: data = 8'h00; 7'd3: data = 8'h00;
        7'd4: data = 8'h00; 7'd5: data = 8'h00;
        7'd6: data = 8'h00; 7'd7: data = 8'h00;
        
        7'd8:  data = 8'h3C; 7'd9:  data = 8'h42; // 0
        7'd10: data = 8'h46; 7'd11: data = 8'h4A;
        7'd12: data = 8'h52; 7'd13: data = 8'h62;
        7'd14: data = 8'h3C; 7'd15: data = 8'h00;
        
        7'd16: data = 8'h08; 7'd17: data = 8'h18; // 1
        7'd18: data = 8'h08; 7'd19: data = 8'h08;
        7'd20: data = 8'h08; 7'd21: data = 8'h08;
        7'd22: data = 8'h1C; 7'd23: data = 8'h00;
        
        7'd24: data = 8'h3C; 7'd25: data = 8'h42; // 2
        7'd26: data = 8'h42; 7'd27: data = 8'h04;
        7'd28: data = 8'h08; 7'd29: data = 8'h10;
        7'd30: data = 8'h7E; 7'd31: data = 8'h00;
        
        7'd32: data = 8'h3C; 7'd33: data = 8'h42; // 3
        7'd34: data = 8'h02; 7'd35: data = 8'h3C;
        7'd36: data = 8'h02; 7'd37: data = 8'h42;
        7'd38: data = 8'h3C; 7'd39: data = 8'h00;
        
        7'd40: data = 8'h1C; 7'd41: data = 8'h24; // 4
        7'd42: data = 8'h44; 7'd43: data = 8'h44;
        7'd44: data = 8'h44; 7'd45: data = 8'h7E;
        7'd46: data = 8'h04; 7'd47: data = 8'h00;
        
        7'd48: data = 8'h7E; 7'd49: data = 8'h40; // 5
        7'd50: data = 8'h40; 7'd51: data = 8'h7C;
        7'd52: data = 8'h02; 7'd53: data = 8'h42;
        7'd54: data = 8'h3C; 7'd55: data = 8'h00;
        
        // --- 補上 6, 7, 8, 9 的字庫 ---
        7'd56: data = 8'h3C; 7'd57: data = 8'h40; // 6
        7'd58: data = 8'h40; 7'd59: data = 8'h7C;
        7'd60: data = 8'h42; 7'd61: data = 8'h42;
        7'd62: data = 8'h3C; 7'd63: data = 8'h00;
        
        7'd64: data = 8'h7E; 7'd65: data = 8'h02; // 7
        7'd66: data = 8'h04; 7'd67: data = 8'h08;
        7'd68: data = 8'h10; 7'd69: data = 8'h10;
        7'd70: data = 8'h10; 7'd71: data = 8'h00;
        
        7'd72: data = 8'h3C; 7'd73: data = 8'h42; // 8
        7'd74: data = 8'h42; 7'd75: data = 8'h3C;
        7'd76: data = 8'h42; 7'd77: data = 8'h42;
        7'd78: data = 8'h3C; 7'd79: data = 8'h00;
        
        7'd80: data = 8'h3C; 7'd81: data = 8'h42; // 9
        7'd82: data = 8'h42; 7'd83: data = 8'h3E;
        7'd84: data = 8'h02; 7'd85: data = 8'h02;
        7'd86: data = 8'h3C; 7'd87: data = 8'h00;
        
        default: data = 8'h00; // 必須要有 default 防止鎖存器 (Latch) 產生
        endcase
    end
endmodule