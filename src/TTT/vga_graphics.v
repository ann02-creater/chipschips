module vga_graphics(
    input  wire        clk,
    input  wire        reset,
    input  wire [9:0]  x,
    input  wire [9:0]  y,
    input  wire        en,
    input  wire [17:0] sw,
    input  wire [8:0]  cell_select_flag,
    input  wire [1:0]  win_flag,
    output reg  [3:0]  red,
    output reg  [3:0]  green,
    output reg  [3:0]  blue
);

    localparam WIDE         = 213;
    localparam HIGH         = 160;
    localparam LINE_W       = 3;
    localparam HIGHLIGHT_W  = 6;
    localparam CIRCLE_OFFSET = 17'h00000;
    localparam X_OFFSET      = 17'h08520;
    localparam COLOR_BLACK = 4'h0;
    localparam COLOR_WHITE = 4'hF;

    wire [9:0] cell_x_pos = (x < WIDE)       ? 10'd0 :
                            (x < 2*WIDE)     ? 10'd1 : 10'd2;
    wire [9:0] cell_y_pos = (y < HIGH)       ? 10'd0 :
                            (y < 2*HIGH)     ? 10'd1 : 10'd2;

    wire [3:0] cell_index = cell_y_pos * 3 + cell_x_pos;
    wire [9:0] rel_x = x - (cell_x_pos * WIDE);
    wire [9:0] rel_y = y - (cell_y_pos * HIGH);
    wire [15:0] base_addr = rel_y * WIDE + rel_x;

    wire [1:0] cell_state = (cell_index < 9) ? sw[cell_index*2 +: 2] : 2'b00;
    wire is_player1 = (cell_state == 2'b01);
    wire is_player2 = (cell_state == 2'b10);
    wire is_occupied = is_player1 || is_player2;

    wire [16:0] piece_addr = is_player1 ? (CIRCLE_OFFSET + base_addr) :
                             is_player2 ? (X_OFFSET + base_addr) :
                             17'h00000;

    wire [11:0] piece_pixel;
    blk_mem_gen_0 u_dual_image_rom (
        .clka(clk),
        .addra(piece_addr),
        .douta(piece_pixel)
    );

    wire [11:0] p1_win_pixel, p2_win_pixel, draw_pixel;
    wire [15:0] win_base_addr = base_addr;

    
    wire is_win_area = (x >= WIDE && x < 2*WIDE) && (y >= HIGH && y < 2*HIGH);
    wire show_win_msg = is_win_area && (win_flag != 2'b00);

    blk_mem_gen_p1win u_p1_win_rom (
        .clka(clk),
        .addra(win_base_addr),
        .douta(p1_win_pixel)
    );

    blk_mem_gen_p2win u_p2_win_rom (
        .clka(clk),
        .addra(win_base_addr),
        .douta(p2_win_pixel)
    );

    blk_mem_gen_draw u_draw_rom (
        .clka(clk),
        .addra(win_base_addr),
        .douta(draw_pixel)
    );

    wire is_piece_pixel = |piece_pixel && is_occupied;
    wire is_win_pixel =
        (win_flag == 2'b01 && p1_win_pixel[0]) ||
        (win_flag == 2'b10 && p2_win_pixel[0]) ||
        (win_flag == 2'b11 && draw_pixel[0]);

    wire is_selected_cell = (cell_index < 9) ? cell_select_flag[cell_index] : 1'b0;

    wire is_border = (rel_x < LINE_W) || (rel_x >= WIDE - LINE_W) ||
                     (rel_y < LINE_W) || (rel_y >= HIGH - LINE_W);

    wire is_highlight = is_selected_cell &&
                        ((rel_x < HIGHLIGHT_W) || (rel_x >= WIDE - HIGHLIGHT_W) ||
                         (rel_y < HIGHLIGHT_W) || (rel_y >= HIGH - HIGHLIGHT_W));

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            red   <= COLOR_BLACK;
            green <= COLOR_BLACK;
            blue  <= COLOR_BLACK;
        end else begin
            if (!en) begin
                red   <= COLOR_BLACK;
                green <= COLOR_BLACK;
                blue  <= COLOR_BLACK;
            end else if (show_win_msg && is_win_pixel) begin
                red   <= COLOR_BLACK;
                green <= COLOR_BLACK;
                blue  <= COLOR_WHITE;
            end else if (is_piece_pixel) begin
                if (is_player1) begin
                    red   <= COLOR_BLACK;
                    green <= COLOR_WHITE;
                    blue  <= COLOR_BLACK;
                end else begin
                    red   <= COLOR_WHITE;
                    green <= COLOR_BLACK;
                    blue  <= COLOR_BLACK;
                end
            end else if (is_highlight) begin
                red   <= COLOR_WHITE;
                green <= COLOR_BLACK;
                blue  <= COLOR_BLACK;
            end else if (is_border) begin
                red   <= COLOR_BLACK;
                green <= COLOR_BLACK;
                blue  <= COLOR_BLACK;
            end else begin
                red   <= COLOR_WHITE;
                green <= COLOR_WHITE;
                blue  <= COLOR_WHITE;
            end
        end
    end

endmodule
