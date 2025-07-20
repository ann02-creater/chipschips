module vga_graphics(
    input  wire       clk,
    input  wire       reset,
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       en,
    input  wire [1:0] board [0:2][0:2], // 총 9칸에 대한 정보를 담고 있음, ttt_ctrl 에서 output을 추가한다는 가정하에
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

// Check if the current cell should show a circle based on corresponding  active_cell;
always @(*) begin // 스위치를 빼고 cell의 위치에 대한 정보를 연결함
    case (cell_index)
        4'd0: active_cell = board[0][0];
        4'd1: active_cell = board[0][1];
        4'd2: active_cell = board[0][2];
        4'd3: active_cell = board[1][0];
        4'd4: active_cell = board[1][1];
        4'd5: active_cell = board[1][2];
        4'd6: active_cell = board[2][0];
        4'd7: active_cell = board[2][1];
        4'd8: active_cell = board[2][2];
        default: active_cell = 1'b0;
    endcase
end
reg [15:0] bram_addr;

always @(*) begin
    bram_addr = rel_y * WIDE + rel_x;
end
wire [11:0] bram_data;

// Instantiate the Block Memory Generator for the circle image
// This BRAM is now local to the graphics module
blk_mem_gen_0 u_image_rom (
    .clka(clk),
    .addra(bram_addr),
    .douta(bram_data)
);


wire [11:0] corrected_color = bram_data;

// A simple check: if any bit in the 8-bit color is set, we consider it part of the circle.
assign mem_pixel = |bram_data; 

// Draw borders for all cells
wire border = (rel_x < LINE_W) || (rel_x >= WIDE - LINE_W) ||
              (rel_y < LINE_W) || (rel_y >= HIGH - LINE_W);

always @(*) begin
    if (!en) begin
        // Off-screen area is black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
    end else if (active_cell && mem_pixel) begin
        // Use converted 8-bit to 12-bit color
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

always @(*) begin
    
end

                   

endmodule