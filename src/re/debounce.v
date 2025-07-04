`timescale 1ns / 1ps

module debounce(
    input wire clk,
    input wire reset,
    input wire btn,
    output reg cnt_en
);
    
    reg Q0, Q1;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            Q0 <= 0;
            Q1 <= 0;
            cnt_en <= 0;
        end else begin
            Q0 <= btn;
            Q1 <= Q0;
            cnt_en <= (Q0 & ~Q1) ? ~cnt_en:cnt_en;
        end
    end

endmodule