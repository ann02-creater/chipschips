module vga_graphics (
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire video_on,
    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
);

localparam CELL_W = 213;   // 640 / 3
localparam CELL_H = 160;   // 480 / 3
localparam LINE_W =   5;

wire [9:0] rel_x = x % CELL_W;
wire [9:0] rel_y = y % CELL_H;

wire border = 
       (rel_x < LINE_W)
    || (rel_x >= CELL_W - LINE_W)
    || (rel_y < LINE_W)
    || (rel_y >= CELL_H - LINE_W);

always @(*) begin
    if (!video_on) begin // black
        red   = 4'h0;
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
