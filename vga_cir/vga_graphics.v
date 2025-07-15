module vga_graphics(
    input  wire     clk, 
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire en,
    input  wire circle_sw,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);

localparam Wide = 213;   // 640 / 3
localparam High = 160;   // 480 / 3
localparam LINE_W =   5;

wire [9:0] rel_x = x % Wide;
wire [9:0] rel_y = y % High;

wire [1:0] cell_x = x / Wide;
wire [1:0] cell_y = y / High;
wire       center = (cell_x == 2'd1) && (cell_y == 2'd1);

wire border =
       (rel_x < LINE_W)
    || (rel_x >= Wide - LINE_W)
    || (rel_y < LINE_W)
    || (rel_y >= High - LINE_W);

wire [17:0] addr = rel_y * WIDE + rel_x;

wire mem_pixel;
  circle_ram U_CIRC (
    .clk     (clk),
    .reset   (1'b0),
    .rd_en   (en && center && circle_sw),
    .rd_addr(addr[15:0]),
    .dout    (mem_pixel)
  );

always @(*) begin
    if (!en) begin // black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
    end else if (mem_pixel) begin //red
        red   = 4'hF;
        green = 4'h0;
        blue  = 4'h0; 
    end else if (border) begin //black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
    end else begin // white
        red   = 4'hF;
        green = 4'hF;
        blue  = 4'hF;
    end
end

endmodule



