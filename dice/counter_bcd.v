`timescale 1ns / 1ps

module counter_bcd(
    input wire clk,
    input wire reset,
    input wire en,
    output reg [3:0] Q,
    output wire TC
);

    always @(posedge clk or negedge reset) begin
        if (!reset)
            Q <= 4'd0;
        else if (en) begin
            if (Q == 4'd9)
                Q <= 4'd0;
            else
                Q <= Q + 1;
        end
    end

    assign TC = (Q == 4'd9) && en;

endmodule
