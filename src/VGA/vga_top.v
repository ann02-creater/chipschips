module vga_top (
    input  wire       clk,
    input  wire       reset,
    output wire       HS,
    output wire       VS,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B
);

    wire clk_25;
    clk25_chain u_clk25 (
        .clk   (clk),
        .reset (reset),
        .clk25 (clk_25)
    );

    wire [9:0] x;
    wire [9:0] y;
    wire       video_on;
    vga_sync u_sync (
        .clk      (clk_25),
        .reset    (reset),
        .x        (x),
        .y        (y),
        .hsync    (HS),
        .vsync    (VS),
        .video_on (video_on)
    );

    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;

    vga_graphics u_grp (
        .x   (x),
        .y   (y),
        .video_on  (video_on),
        .red   (red),
        .green (green),
        .blue  (blue)
    );

    assign VGA_R = red;
    assign VGA_G = green;
    assign VGA_B = blue;

endmodule
