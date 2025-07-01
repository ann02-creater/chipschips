`timescale 1ns / 1ps

module debounce(
    input wire clk,
    input wire reset,
    input wire btn,
    output reg toggle
);

    reg [19:0] counter;
    reg btn_prev;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 20'd0;
            btn_prev <= 1'b0;
            toggle <= 1'b0;
        end else begin
            if (btn != btn_prev) begin
                counter <= 20'd0;
                btn_prev <= btn;
            end else if (counter < 20'd999999) begin
                counter <= counter + 1;
            end else begin
                toggle <= btn;
            end
        end
    end

endmodule