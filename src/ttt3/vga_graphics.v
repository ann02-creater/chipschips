module vga_graphics (
    input  wire        pixel_clk,
    input  wire        video_on,
    input  wire [9:0]  x,
    input  wire [9:0]  y,
    input  wire [8:0]  board_p1,
    input  wire [8:0]  board_p2,
    input  wire [8:0]  cursor_flag,
    output reg  [3:0]  red,
    output reg  [3:0]  green,
    output reg  [3:0]  blue
);

    localparam WIDE   = 640/3;
    localparam HIGH   = 480/3;
    localparam LINE_W = 3;

    wire [1:0] cell_x  = x / WIDE;
    wire [1:0] cell_y  = y / HIGH;
    wire [3:0] idx     = cell_y * 3 + cell_x;
    wire [9:0] rel_x   = x % WIDE;
    wire [9:0] rel_y   = y % HIGH;

    wire [15:0] bram_addr = rel_y * WIDE + rel_x;

    wire [11:0] rom_x;
    blk_mem_gen_X u_rom_x (
        .clka  (pixel_clk),
        .addra (bram_addr),
        .douta (rom_x)
    );

    wire [11:0] rom_o;
    blk_mem_gen_O u_rom_o (
        .clka  (pixel_clk),
        .addra (bram_addr),
        .douta (rom_o)
    );

    wire x_pixel = board_p1[idx] && |rom_x;
    wire o_pixel = board_p2[idx] && |rom_o;

    wire border = (rel_x < LINE_W)             
                || (rel_x >= WIDE - LINE_W)  
                || (rel_y < LINE_W)          
                || (rel_y >= HIGH - LINE_W);

    always @(*) begin
        if (!video_on) begin
            red   = 4'd0; green = 4'd0; blue  = 4'd0;
        end else if (cursor_flag[idx]) begin
            red   = 4'hF; green = 4'hF; blue  = 4'h0;
        end else if (x_pixel) begin
            red   = rom_x[11:8];
            green = rom_x[7:4];
            blue  = rom_x[3:0];
        end else if (o_pixel) begin
            red   = rom_o[11:8];
            green = rom_o[7:4];
            blue  = rom_o[3:0];
        end else if (border) begin
            red   = 4'd0; green = 4'd0; blue  = 4'd0;
        end else begin
            red   = 4'hF; green = 4'hF; blue  = 4'hF;
        end
    end

endmodule
