// Clock Wizard replacement module
// Generates 25MHz from 100MHz input clock

module clk_wiz_0 (
    input  wire clk_in,
    input  wire reset,
    output reg  clk25,
    output wire locked
);

    // Simple clock divider (100MHz / 4 = 25MHz)
    reg [1:0] clk_div_counter = 2'b00;
    
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            clk_div_counter <= 2'b00;
            clk25 <= 1'b0;
        end else begin
            clk_div_counter <= clk_div_counter + 1;
            if (clk_div_counter == 2'b11) begin
                clk25 <= ~clk25;
            end
        end
    end
    
    // Simple lock signal (always locked after reset)
    reg [7:0] lock_counter = 8'h00;
    reg locked_reg = 1'b0;
    
    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            lock_counter <= 8'h00;
            locked_reg <= 1'b0;
        end else if (!locked_reg) begin
            lock_counter <= lock_counter + 1;
            if (lock_counter == 8'hFF) begin
                locked_reg <= 1'b1;
            end
        end
    end
    
    assign locked = locked_reg;

endmodule