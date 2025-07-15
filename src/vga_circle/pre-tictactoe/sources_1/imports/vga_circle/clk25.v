module clk25 (
    input  wire clk,
    input  wire reset,
    output wire clk25
);
    wire q0;
    counter #(
        .MaxCount  (3),
        .DataWidth (2)
    ) U_DIV4 (
        .clk   (clk),
        .reset (reset),
        .en    (1'b1),
        .Q     (clk25),
        .TC    ()
    );


endmodule
