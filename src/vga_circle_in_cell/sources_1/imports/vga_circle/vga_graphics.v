module vga_graphics(
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       en,
    input  wire [8:0] sw, // 9-bit switch input for 9 cells
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

// Calculate cell index (0-8) from 3x3 grid position
wire [3:0] cell_index = cell_y * 3 + cell_x;


// Check if the current cell should show a circle based on corresponding switch
reg active_cell;
always @(*) begin
    case (cell_index)
        4'd0: active_cell = sw[0];
        4'd1: active_cell = sw[1];
        4'd2: active_cell = sw[2];
        4'd3: active_cell = sw[3];
        4'd4: active_cell = sw[4];
        4'd5: active_cell = sw[5];
        4'd6: active_cell = sw[6];
        4'd7: active_cell = sw[7];
        4'd8: active_cell = sw[8];
        default: active_cell = 1'b0;
    endcase
end
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

wire [7:0] rgb8_from_bram = bram_data[7:0]; 
wire [11:0] corrected_color;
// Correct the color format to match the VGA output
// The BRAM data is assumed to be in RGB format, we need to convert it to
// the 12-bit format used by VGA (R[3:0], G[3:0], B[3:0])
// The conversion is done by shifting the bits to fit
assign corrected_color = {rgb8_from_bram[7:6], 2'b00, rgb8_from_bram[5:3], 1'b0, rgb8_from_bram[2:0], 1'b0};

always @(*) begin
     if (!en) begin
        // Off-screen area is black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
     end else if (active_cell && mem_pixel) begin
         // 변환된 색상 값을 사용합니다.
         // corrected_color는 {R, G, B} 순서로 되어 있습니다.
        red   = corrected_color[11:8];
        green = corrected_color[7:4];
        blue  = corrected_color[3:0];
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