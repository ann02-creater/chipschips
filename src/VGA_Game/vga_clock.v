module clk25_chain (
    input  wire clk,
    input  wire reset,
    output wire clk25
);
    wire q0;

    counter #(
        .MaxCount  (3),
        .DataWidth (2)
    ) U_DIV2_1 (
        .clk   (clk),
        .reset (reset),
        .en    (1'b1),
        .Q     (q0),
        .TC    ()
    );

    assign clk25 = q0[1];

endmodule
