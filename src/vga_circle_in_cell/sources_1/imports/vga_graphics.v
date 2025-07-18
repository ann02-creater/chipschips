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

// Cell dimensions (640/3, 480/3) - reduced by 10 pixels each
localparam WIDE = 203;
localparam HIGH = 150;
localparam LINE_W = 5;

// Calculate relative coordinates within a cell
reg [9:0] rel_x;// 셀 내부에서의 x좌표(0~202)
reg [9:0] rel_y;// 셀 내부에서의 y좌표(0~149)

// Calculate which cell the current (x,y) is in
reg [1:0] cell_x;//몇번째 열인지(0,1,2)
reg [1:0] cell_y;//몇번째 행인지(0,1,2)

// Calculate cell index (0-8) from 3x3 grid position
reg [3:0] cell_index;

always @(*) begin
    if (x < WIDE) begin //x<213
        rel_x = x; //셀 내 상대좌표 = 절대 좌표
        cell_x = 0;//첫번째 열
    end else if (x < 2*WIDE) begin //213<= x <426
        rel_x = x - WIDE; //셀내 상대좌표 = 절대 좌표 - 셀 너비
        cell_x = 1; //두번째 열
    end else begin //x >= 426
        rel_x = x - 2*WIDE; //셀내 상대좌표 = 절대 좌표 - 2 * 셀 너비
        cell_x = 2; //세번째 열
    end
    
    if (y < HIGH) begin //y<160
        rel_y = y; //셀 내 상대좌표 = 절대 좌표
        cell_y = 0; //첫번째 행
    end else if (y < 2*HIGH) begin 
        rel_y = y - HIGH; //셀내 상대좌표 = 절대 좌표 - 셀 높이
        cell_y = 1;//두번째 행
    end else begin
        rel_y = y - 2*HIGH; //셀내 상대좌표 = 절대 좌표 - 2 * 셀 높이
        cell_y = 2;//세번째 행
    end
    
    cell_index = cell_y * 3 + cell_x;/*첫번째 셀부터 0,1,2,
                                                  3,4,5,
                                                  6,7,8 의 순서로 인덱스 계산*/
end


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

reg [15:0] bram_addr;// 셀내 상대좌표를 BRAM의 선형 주소로 변환

always @(*) begin
    bram_addr = rel_y * WIDE + rel_x;// 주소 = 행번호*폭 + 열번호
end

// Instantiate the Block Memory Generator for the circle image
// This BRAM is now local to the graphics module
blk_mem_gen_0 u_image_rom (
    .clka(clk),
    .addra(bram_addr),
    .douta(bram_data)
);



wire [11:0] bram_data;//BRAM에서 읽어온 12비트 색상 데이터
wire mem_pixel; // 현재 픽셀이 원의 일부인지 판단하는 불린 신호
assign mem_pixel = |bram_data; // 1= 색상 데이터 있음 , 0= 모든 비트가 0이므로 배경영역임.

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