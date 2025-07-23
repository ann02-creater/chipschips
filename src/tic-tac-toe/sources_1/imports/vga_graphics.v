module vga_graphics(
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       en,
    input  wire [17:0] sw,  // Changed from 9-bit to 18-bit (2 bits per cell)
    input  wire [8:0] cell_select_flag,
    output reg  [3:0] red,
    output reg  [3:0] green,
    output reg  [3:0] blue
);

// Cell dimensions
localparam WIDE = 213;
localparam HIGH = 160;
localparam LINE_W = 3;
localparam HIGHLIGHT_W = 6;

// Image address offsets
localparam CIRCLE_OFFSET = 17'h00000;  // Circle image starts at 0
localparam X_OFFSET = 17'h08500;       // X image starts at 0x8500

// Color definitions
localparam COLOR_BLACK = 4'h0;
localparam COLOR_WHITE = 4'hF;

// Cell position calculation
wire [9:0] cell_x_pos = (x < WIDE) ? 10'd0 : (x < 2*WIDE) ? 10'd1 : 10'd2;
wire [9:0] cell_y_pos = (y < HIGH) ? 10'd0 : (y < 2*HIGH) ? 10'd1 : 10'd2;
wire [3:0] cell_index = {2'b00, cell_y_pos[1:0]} * 3 + {2'b00, cell_x_pos[1:0]};

// Relative position within cell
wire [9:0] rel_x = x - (cell_x_pos * WIDE);
wire [9:0] rel_y = y - (cell_y_pos * HIGH);

// Get cell state (2 bits per cell)
wire [1:0] cell_state = (cell_index < 9) ? sw[cell_index*2 +: 2] : 2'b00;
wire is_player1 = (cell_state == 2'b01);
wire is_player2 = (cell_state == 2'b10);
wire is_occupied = is_player1 || is_player2;

// Memory address calculation
wire [15:0] base_addr = rel_y * WIDE + rel_x;
wire [16:0] bram_addr = is_player1 ? (CIRCLE_OFFSET + base_addr) : 
                        is_player2 ? (X_OFFSET + base_addr) : 
                        17'h00000;

wire [11:0] bram_data;

// Block RAM for dual image (circle and X)
blk_mem_gen_0 u_dual_image_rom (
    .clka(clk),
    .addra(bram_addr),
    .douta(bram_data)
);

// Pixel detection
wire is_image_pixel = |bram_data && is_occupied;
wire is_selected_cell = (cell_index < 9) ? cell_select_flag[cell_index] : 1'b0;

// Border detection
wire is_border = (rel_x < LINE_W) || (rel_x >= WIDE - LINE_W) ||
                 (rel_y < LINE_W) || (rel_y >= HIGH - LINE_W);

wire is_highlight = is_selected_cell && 
                    ((rel_x < HIGHLIGHT_W) || (rel_x >= WIDE - HIGHLIGHT_W) ||
                     (rel_y < HIGHLIGHT_W) || (rel_y >= HIGH - HIGHLIGHT_W));

// Color output logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        red   <= COLOR_BLACK;
        green <= COLOR_BLACK;
        blue  <= COLOR_BLACK;
    end else begin
        if (!en) begin
            // Off-screen: black
            red   <= COLOR_BLACK;
            green <= COLOR_BLACK;
            blue  <= COLOR_BLACK;
        end else if (is_image_pixel) begin
            if (is_player1) begin
                // Green circle for player 1
                red   <= COLOR_BLACK;
                green <= COLOR_WHITE;
                blue  <= COLOR_BLACK;
            end else begin
                // Red X for player 2
                red   <= COLOR_WHITE;
                green <= COLOR_BLACK;
                blue  <= COLOR_BLACK;
            end
        end else if (is_highlight) begin
            // Red highlight border
            red   <= COLOR_WHITE;
            green <= COLOR_BLACK;
            blue  <= COLOR_BLACK;
        end else if (is_border) begin
            // Black border
            red   <= COLOR_BLACK;
            green <= COLOR_BLACK;
            blue  <= COLOR_BLACK;
        end else begin
            // White background
            red   <= COLOR_WHITE;
            green <= COLOR_WHITE;
            blue  <= COLOR_WHITE;
        end
    end
end

endmodule