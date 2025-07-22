module vga_graphics (
    input  wire        pixel_clk,
    input  wire        en,
    input  wire [9:0]  x,
    input  wire [9:0]  y,
    input  wire [8:0]  cursor_pos,
    input  wire [8:0]  board,
    output reg  [3:0]  red,
    output reg  [3:0]  green,
    output reg  [3:0]  blue
);

  localparam CELL_W    = 640/3;
  localparam CELL_H    = 480/3;
  localparam GRID_W    = 3;
  localparam HIGHLIGHT = 8;

  wire [1:0] cell_x = x / CELL_W;
  wire [1:0] cell_y = y / CELL_H;
  wire [3:0] idx    = cell_y * 3 + cell_x;
  wire [9:0] rel_x  = x % CELL_W;
  wire [9:0] rel_y  = y % CELL_H;

  wire grid_v    = (x == CELL_W) || (x == 2*CELL_W);
  wire grid_h    = (y == CELL_H) || (y == 2*CELL_H);
  wire highlight = cursor_pos[idx] && (
                       rel_x < HIGHLIGHT || rel_x >= CELL_W - HIGHLIGHT ||
                       rel_y < HIGHLIGHT || rel_y >= CELL_H - HIGHLIGHT
                   );
  wire render_O  = board[idx];

  wire [15:0] addr = rel_y * CELL_W + rel_x;
  wire [11:0] o_data;
  blk_mem_gen_circle u_o_rom (
    .clka(pixel_clk),
    .addra(addr),
    .douta(o_data)
  );

  wire o_pixel = render_O && |o_data;

  always @(posedge pixel_clk) begin
    if (!video_on) begin
      red   <= 4'h0;
      green <= 4'h0;
      blue  <= 4'h0;
    end else if (grid_v || grid_h) begin
      red   <= 4'h0;
      green <= 4'h0;
      blue  <= 4'h0;
    end else if (o_pixel) begin
      red   <= o_data[11:8];
      green <= o_data[7:4];
      blue  <= o_data[3:0];
    end else if (highlight) begin
      red   <= 4'hF;
      green <= 4'hF;
      blue  <= 4'h0;
    end else begin
      red   <= 4'hF;
      green <= 4'hF;
      blue  <= 4'hF;
    end
  end

endmodule
