module vga_graphics(
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       en,
    input  wire       sw,
    output reg [3:0]  red,
    output reg [3:0]  green,
    output reg [3:0]  blue
);

localparam CELL_W = 213;   // 640 / 3
localparam CELL_H = 160;   // 480 / 3
localparam LINE_W =   5;

// Circle parameters
localparam CIRCLE_R = 40;
localparam CIRCLE_CX = CELL_W / 2;
localparam CIRCLE_CY = CELL_H / 2;

wire [9:0] rel_x = x % CELL_W;
wire [9:0] rel_y = y % CELL_H;

wire border =
       (rel_x < LINE_W)
    || (rel_x >= CELL_W - LINE_W)
    || (rel_y < LINE_W)
    || (rel_y >= CELL_H - LINE_W);

// Signed values for circle calculation
wire signed [10:0] dx = rel_x - CIRCLE_CX;
wire signed [10:0] dy = rel_y - CIRCLE_CY;
wire in_circle = (dx*dx + dy*dy) < (CIRCLE_R * CIRCLE_R);

// Check if we are in the first cell
wire in_first_cell = (x < CELL_W) && (y < CELL_H);

always @(*) begin
    if (!en) begin // Screen off, black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
    end else if (border) begin // Cell border, black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
    end else if (sw && in_first_cell && in_circle) begin // Green circle in the first cell
        red   = 4'h0;
        green = 4'hF;
        blue  = 4'h0;
    end else begin // Cell background, white
        red   = 4'hF;
        green = 4'hF;
        blue  = 4'hF;
    end
end

endmodule



