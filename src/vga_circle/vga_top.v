module vga_top (
    input  wire       clk,
    input  wire       reset,
    input  wire [0:0] switches,
    output wire       VGA_HS,
    output wire       VGA_VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
);

    wire clk25;
    clk25 u_clk25 (
        .clk   (clk),
        .reset (reset),
        .clk25 (clk25)
    );

    wire [9:0] x;
    wire [9:0] y;
    wire       en;
    vga_sync u_sync (
        .clk      (clk25),
        .reset    (reset),
        .x        (x),
        .y        (y),
        .hsync    (VGA_HS),
        .vsync    (VGA_VS),
        .en (en)
    );

    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;

    vga_graphics u_grp (
        .x     (x),
        .y     (y),
        .en    (en),
        .sw    (switches[0]),
        .red   (red),
        .green (green),
        .blue  (blue)
    );

    assign VGA_R = red;
    assign VGA_G = green;
    assign VGA_B = blue;

endmodule
