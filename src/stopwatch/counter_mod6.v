module counter_mod6(
    input wire clk,
    input wire reset,
    input wire en,
    output reg [2:0] Q,
    output wire tc
);

    assign tc = (Q == 3'd5) && en;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Q <= 3'd0;
        end else if (en) begin
            if (Q == 3'd5)
                Q <= 3'd0;
            else
                Q <= Q + 1;
        end
    end

endmodule
