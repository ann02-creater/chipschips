module counter_bcd(
    input wire clk,
    input wire reset,
    input wire en,
    output reg [3:0] Q,
    output wire TC
);

    assign TC = (Q == 4'd9) && en;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Q <= 4'd0;
        end else if (en) begin
            if (Q == 4'd9)
                Q <= 4'd0;
            else
                Q <= Q + 1;
        end
    end

endmodule
