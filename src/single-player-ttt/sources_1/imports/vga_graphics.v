module vga_graphics(
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       en,
    input  wire [8:0] sw,
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

// Cell position calculation
wire [9:0] cell_x_pos = (x < WIDE) ? 10'd0 : (x < 2*WIDE) ? 10'd1 : 10'd2;
wire [9:0] cell_y_pos = (y < HIGH) ? 10'd0 : (y < 2*HIGH) ? 10'd1 : 10'd2;
wire [3:0] cell_index = {2'b00, cell_y_pos[1:0]} * 3 + {2'b00, cell_x_pos[1:0]};

// Relative position within cell
wire [9:0] rel_x = x - (cell_x_pos * WIDE);
wire [9:0] rel_y = y - (cell_y_pos * HIGH);

// Memory address calculation
wire [15:0] bram_addr = rel_y * WIDE + rel_x;
wire [11:0] bram_data;

// Block RAM for circle image
blk_mem_gen_0 u_circle_rom (
    .clka(clk),
    .addra(bram_addr),
    .douta(bram_data)
);

// Pixel detection
wire is_circle_pixel = |bram_data;
wire is_active_cell = (cell_index < 9) ? sw[cell_index] : 1'b0;
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
        red   <= 4'h0;
        green <= 4'h0;
        blue  <= 4'h0;
    end else begin
        if (!en) begin
            // Off-screen: black
            red   <= 4'h0;
            green <= 4'h0;
            blue  <= 4'h0;
        end else if (is_active_cell && is_circle_pixel) begin
            // Green circle
            red   <= 4'h0;
            green <= 4'hF;
            blue  <= 4'h0;
        end else if (is_highlight) begin
            // Red highlight border
            red   <= 4'hF;
            green <= 4'h0;
            blue  <= 4'h0;
        end else if (is_border) begin
            // Black border
            red   <= 4'h0;
            green <= 4'h0;
            blue  <= 4'h0;
        end else begin
            // White background
            red   <= 4'hF;
            green <= 4'hF;
            blue  <= 4'hF;
        end
    end
end

endmodule