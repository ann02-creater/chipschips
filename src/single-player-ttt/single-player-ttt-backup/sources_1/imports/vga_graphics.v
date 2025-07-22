module vga_graphics(
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       en,
    input  wire [8:0] sw, // 9-bit input for 9 cells 
    input  wire [8:0] cell_select_flag, // One-hot encoding for cursor position
    output reg  [3:0] red,
    output reg  [3:0] green,
    output reg  [3:0] blue
);

// Cell dimensions (640/3, 480/3)
localparam WIDE = 213;
localparam HIGH = 160;
localparam LINE_W = 3;

// Calculate relative coordinates within a cell using wire (like reference)
wire [9:0] rel_x = (x < WIDE) ? x : 
                   (x < 2*WIDE) ? x - WIDE : 
                   x - 2*WIDE;
wire [9:0] rel_y = (y < HIGH) ? y : 
                   (y < 2*HIGH) ? y - HIGH : 
                   y - 2*HIGH;

// Calculate which cell the current (x,y) is in
wire [1:0] cell_x = (x < WIDE) ? 2'd0 : (x < 2*WIDE) ? 2'd1 : 2'd2;
wire [1:0] cell_y = (y < HIGH) ? 2'd0 : (y < 2*HIGH) ? 2'd1 : 2'd2;

// Calculate cell index (0-8) from 3x3 grid position
wire [3:0] cell_index = cell_y * 3 + cell_x;


// Check if the current cell should show a circle (simplified like reference)
wire active_cell = (cell_index < 9) ? sw[cell_index] : 1'b0;

// Calculate BRAM address using wire
wire [15:0] bram_addr = rel_y * WIDE + rel_x;
wire [11:0] bram_data;

// Instantiate the Block Memory Generator for the Circle image
blk_mem_gen_0 u_circle_image_rom (
    .clka(clk),
    .addra(bram_addr),
    .douta(bram_data)
);

// Check if current pixel is part of the image (not background)
wire mem_pixel = |bram_data; 

// Draw borders for all cells
wire border = (rel_x < LINE_W) || (rel_x >= WIDE - LINE_W) ||
              (rel_y < LINE_W) || (rel_y >= HIGH - LINE_W);

// Check if current cell is selected (cursor highlight)
wire cell_selected = cell_select_flag[cell_index];
wire cursor_highlight = cell_selected && ((rel_x < LINE_W*2) || (rel_x >= WIDE - LINE_W*2) ||
                                         (rel_y < LINE_W*2) || (rel_y >= HIGH - LINE_W*2));

always @(*) begin
    if (!en) begin
        // Off-screen area is black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
    end else if (active_cell && mem_pixel) begin
        // Display green circle (fixed color)
        red   = 4'h0;
        green = 4'hF;
        blue  = 4'h0;
    end else if (cursor_highlight) begin
        // Cursor highlight - yellow border (강제 노란색)
        red   = 4'hF;
        green = 4'hF;
        blue  = 4'h0;
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
