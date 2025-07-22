module ttt_practice_top (
    input  wire        clk,
    input  wire        reset,
    input  wire        clk_9600,
    input  wire        pixel_clk,
    input  wire        rx_data,
    output wire        vga_hs,
    output wire        vga_vs,
    output wire [3:0]  vga_r,
    output wire [3:0]  vga_g,
    output wire [3:0]  vga_b
);

  wire        w, a, s, d, enter;
  wire        data_valid, parity_error;
  wire [7:0]  rx_ascii;

  ttt_rx u_rx (
    .clk_9600     (clk_9600),
    .reset        (reset),
    .rx_data      (rx_data),
    .w            (w),
    .a            (a),
    .s            (s),
    .d            (d),
    .enter        (enter),
    .data_valid   (data_valid),
    .parity_error (parity_error),
    .rx_ascii_reg (rx_ascii)
  );

  wire [8:0]  cursor_pos;
  wire [8:0]  board;
  wire        draw_trigger;

  ttt_ctrl u_ctrl (
    .clk          (clk),
    .reset        (reset),
    .w            (w),
    .a            (a),
    .s            (s),
    .d            (d),
    .enter        (enter),
    .cursor_pos   (cursor_pos),
    .board        (board),
    .draw_trigger (draw_trigger)
  );

  wire        en;
  wire [9:0]  x;
  wire [9:0]  y;

  vga_sync u_sync (
    .pixel_clk (pixel_clk),
    .reset     (reset),
    .hsync     (vga_hs),
    .vsync     (vga_vs),
    .en        (en),
    .x         (x),
    .y         (y)
  );

  vga_graphics u_graphics (
    .pixel_clk  (pixel_clk),
    .en         (en),
    .x          (x),
    .y          (y),
    .cursor_pos (cursor_pos),
    .board      (board),
    .red        (vga_r),
    .green      (vga_g),
    .blue       (vga_b)
  );

endmodule
