module vga_graphics(
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       en,
    input  wire [17:0] sw, // 18-bit input for 9 cells (2 bits each)
    input  wire [8:0] cell_select_flag, // One-hot encoding for cursor position
    output reg  [3:0] red,
    output reg  [3:0] green,
    output reg  [3:0] blue
);

// Cell dimensions (640/3, 480/3)
localparam WIDE = 213;
localparam HIGH = 160;
localparam LINE_W = 3;

// Calculate relative coordinates within a cell
reg [9:0] rel_x;
reg [9:0] rel_y;

// Calculate which cell the current (x,y) is in
reg [1:0] cell_x;
reg [1:0] cell_y;

// Calculate cell index (0-8) from 3x3 grid position
reg [3:0] cell_index;

always @(*) begin
    if (x < WIDE) begin
        rel_x = x;
        cell_x = 0;
    end else if (x < 2*WIDE) begin
        rel_x = x - WIDE;
        cell_x = 1;
    end else begin
        rel_x = x - 2*WIDE;
        cell_x = 2;
    end
    
    if (y < HIGH) begin
        rel_y = y;
        cell_y = 0;
    end else if (y < 2*HIGH) begin
        rel_y = y - HIGH;
        cell_y = 1;
    end else begin
        rel_y = y - 2*HIGH;
        cell_y = 2;
    end
    
    cell_index = cell_y * 3 + cell_x;
end


wire mem_pixel; // Explicitly declare the wire for the memory pixel

// Get cell state from 2-bit values (00:empty, 01:X, 10:O)
reg [1:0] cell_state;
always @(*) begin
    case (cell_index)
        4'd0: cell_state = sw[1:0];
        4'd1: cell_state = sw[3:2];
        4'd2: cell_state = sw[5:4];
        4'd3: cell_state = sw[7:6];
        4'd4: cell_state = sw[9:8];
        4'd5: cell_state = sw[11:10];
        4'd6: cell_state = sw[13:12];
        4'd7: cell_state = sw[15:14];
        4'd8: cell_state = sw[17:16];
        default: cell_state = 2'b00;
    endcase
end

wire is_X = (cell_state == 2'b01);
wire is_O = (cell_state == 2'b10);
wire is_empty = (cell_state == 2'b00);
reg [15:0] bram_addr;

always @(*) begin
    bram_addr = rel_y * WIDE + rel_x;
end
wire [11:0] o_bram_data;
wire [11:0] x_bram_data;

// Instantiate the Block Memory Generator for the O image (circle)
blk_mem_gen_0 u_o_image_rom (
    .clka(clk),
    .addra(bram_addr),
    .douta(o_bram_data)
);

// Instantiate the Block Memory Generator for the X image  
blk_mem_gen_0_1 u_x_image_rom (
    .clka(clk),
    .addra(bram_addr),
    .douta(x_bram_data)
);


// Select image data based on cell state
wire [11:0] selected_image_data = is_X ? x_bram_data : o_bram_data;
wire [11:0] corrected_color = selected_image_data;

// Check if current pixel is part of the image (not background)
assign mem_pixel = is_X ? |x_bram_data : |o_bram_data; 

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
    end else if ((is_X || is_O) && mem_pixel) begin
        // Display X or O image
        red   = corrected_color[11:8];
        green = corrected_color[7:4];
        blue  = corrected_color[3:0];
    end else if (cursor_highlight) begin
        // Cursor highlight - yellow border
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
