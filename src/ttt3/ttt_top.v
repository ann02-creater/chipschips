module ttt_practice_top (
    input  wire        clk,
    input  wire        reset,
    input  wire        up,
    input  wire        down,
    input  wire        left,
    input  wire        right,
    input  wire        enter,
    input  wire        space,
    output wire        vga_hs,
    output wire        vga_vs,
    output wire [3:0]  vga_r,
    output wire [3:0]  vga_g,
    output wire [3:0]  vga_b
);

    wire pixel_clk;
    clk25_chain UCLK (
        .clk   (clk),
        .reset (reset),
        .clk25 (pixel_clk)
    );

    wire [3:0]  current_cell;
    wire [8:0]  cell_select_flag;
    wire [8:0]  board_out1;
    wire [8:0]  board_out2;
    wire        turn;

    ttt_crtl UCTRL (
        .clk             (clk),
        .reset           (reset),
        .up              (up),
        .down            (down),
        .left            (left),
        .right           (right),
        .enter           (enter),
        .space           (space),
        .current_cell    (current_cell),
        .cell_select_flag(cell_select_flag),
        .board_out1      (board_out1),
        .board_out2      (board_out2),
        .turn            (turn)
    );

    wire        video_on;
    wire [9:0]  x;
    wire [9:0]  y;

    vga_sync USYNC (
        .clk      (pixel_clk),
        .reset    (reset),
        .hsync    (vga_hs),
        .vsync    (vga_vs),
        .video_on (video_on),
        .x        (x),
        .y        (y)
    );

    vga_graphics_image UGRAPH (
        .pixel_clk    (pixel_clk),
        .video_on     (video_on),
        .x            (x),
        .y            (y),
        .board_p1     (board_out1),
        .board_p2     (board_out2),
        .cursor_flag  (cell_select_flag),
        .red          (vga_r),
        .green        (vga_g),
        .blue         (vga_b)
    );

endmodule
