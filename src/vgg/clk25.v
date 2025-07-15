module clk25 (
    input  wire clk,
    input  wire reset,
    output wire clk25
);
    reg [1:0] r_count;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_count <= 2'b0;
        end else begin
            r_count <= r_count + 1;
        end
    end

    assign clk25 = r_count[1];

endmodule
