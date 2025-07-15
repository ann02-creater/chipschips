module vga_graphics(
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       en,
    input  wire [3:0] sw, // 4-bit switch input
    output reg  [3:0] red,
    output reg  [3:0] green,
    output reg  [3:0] blue
);

// Cell dimensions (640/3, 480/3)
localparam WIDE = 213;
localparam HIGH = 160;
localparam LINE_W = 5;

// Calculate relative coordinates within a cell
wire [9:0] rel_x = x % WIDE;
wire [9:0] rel_y = y % HIGH;

// Calculate which cell the current (x,y) is in
wire [1:0] cell_x = x / WIDE;
wire [1:0] cell_y = y / HIGH;

// Determine target cell based on switch input
// sw[1:0] for x, sw[3:2] for y
wire [1:0] target_cell_x = sw[1:0];
wire [1:0] target_cell_y = sw[3:2];

// Check if the current pixel is within the user-selected cell
wire active_cell = (cell_x == target_cell_x) && (cell_y == target_cell_y);

// BRAM address based on relative coordinates
wire [18:0] bram_addr = rel_y * WIDE + rel_x;
wire [11:0] bram_data;
wire        mem_pixel;

// Instantiate the Block Memory Generator for the circle image
// This BRAM is now local to the graphics module
blk_mem_gen_0 u_image_rom (
    .clka(clk),
    .addra(bram_addr),
    .douta(bram_data)
);

// For this design, we assume the circle is pre-loaded into the BRAM.
// The circle_ram module is not needed if a .coe file is used with blk_mem_gen_0.
// We will use the direct output of the BRAM.
// A simple check: if any bit in the 12-bit color is set, we consider it part of the circle.
assign mem_pixel = |bram_data; 

// Draw borders for all cells
wire border = (rel_x < LINE_W) || (rel_x >= WIDE - LINE_W) ||
              (rel_y < LINE_W) || (rel_y >= HIGH - LINE_W);

always @(*) begin
    if (!en) begin
        // Off-screen area is black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
    end else if (active_cell && mem_pixel) begin
        // If in the active cell and the BRAM pixel is set, draw the image color (e.g., red)
        red   = bram_data[11:8];
        green = bram_data[7:4];
        blue  = bram_data[3:0];
    end else if (border) begin
        // Cell borders are black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
    end else begin
        // Cell background is white
        red   = 4'hF;
        green = 4'hF;
        blue  = 4'hF;
    end
end

endmodule