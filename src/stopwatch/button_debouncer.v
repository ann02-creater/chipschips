`timescale 1ns / 1ps

module button_debouncer(
    input wire clk,
    input wire clk_1ms,
    input wire rst_n,
    input wire btn_in,
    output reg btn_out,
    output wire btn_edge
);

    reg [7:0] shift_reg;
    reg btn_sync1, btn_sync2;
    reg btn_stable;
    reg btn_prev;
    reg clk_1ms_prev;
    wire clk_1ms_edge;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_1ms_prev <= 1'b0;
        end else begin
            clk_1ms_prev <= clk_1ms;
        end
    end
    
    assign clk_1ms_edge = clk_1ms & ~clk_1ms_prev;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync1 <= 1'b0;
            btn_sync2 <= 1'b0;
        end else begin
            btn_sync1 <= btn_in;
            btn_sync2 <= btn_sync1;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 8'b00000000;
            btn_stable <= 1'b0;
        end else if (clk_1ms_edge) begin
            shift_reg <= {shift_reg[6:0], btn_sync2};
            
            if (shift_reg == 8'b11111111) begin
                btn_stable <= 1'b1;
            end else if (shift_reg == 8'b00000000) begin
                btn_stable <= 1'b0;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_out <= 1'b0;
            btn_prev <= 1'b0;
        end else begin
            btn_out <= btn_stable;
            btn_prev <= btn_stable;
        end
    end
    
    assign btn_edge = btn_stable & ~btn_prev;

endmodule