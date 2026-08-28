module key_code_mux(display_code, sel, key_code);
    input [23:0] display_code;
    input [2:0] sel;
    output [3:0] key_code;
    
    assign key_code = (sel == 3'b101) ? display_code[3:0] :
                      (sel == 3'b100) ? display_code[7:4] :
                      (sel == 3'b011) ? display_code[11:8] :
                      (sel == 3'b010) ? display_code[15:12] :
                      (sel == 3'b001) ? display_code[19:16] :
                      (sel == 3'b000) ? display_code[23:20] : 
                      4'b1111;
endmodule