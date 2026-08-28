module debounce_ctl (clk, rst, press, press_valid);
    input press, clk, rst;
    output press_valid;
    reg [5:0] gg; 

    assign press_valid = ~(gg[5] || (~press)); //
    
    always@(posedge clk or posedge rst) begin
        if(rst)
            gg <= 6'b0; //
        else
            gg <= {gg[4:0], press}; //
    end
endmodule