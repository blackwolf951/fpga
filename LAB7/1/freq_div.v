module freq_div(clk_in, reset, clk_out);
    parameter exp = 20;   
    input clk_in, reset;
    output clk_out;
    
    reg [exp-1:0] divider;
    
    assign clk_out = divider[exp-1];
    
    always @(posedge clk_in or posedge reset) begin
        if (reset)
            divider <= 0; // 改用 <= 且直接給 0 即可清空[cite: 2]
        else
            divider <= divider + 1'b1; // 循序邏輯請一律使用 <=[cite: 2]
    end
endmodule