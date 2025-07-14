module renderer(
    input wire [9:0] x, y,
    input wire en,
    input wire [8:0] board,
    input wire [3:0] cursor,
    output reg [3:0] VGA_R, VGA_G, VGA_B
);
    localparam BLACK=0, RED=1, GREEN=2, WHITE=15;
    reg [3:0] r,g,b;
    wire [1:0] cell_x = x / 213;
    wire [1:0] cell_y = y / 160;
    wire [3:0] cell = cell_y * 3 + cell_x;

   
    always @(*) begin
        if(video_on) begin
            if(board[cell]==1) begin // Player 1 is RED
                r = 4'hF; g = 4'h0; b = 4'h0;
            end
            else if(board[cell]==2) begin // Player 2 is GREEN
                r = 4'h0; g = 4'hF; b = 4'h0;
            end
            else begin // Empty cell is BLACK
                r = 4'h0; g = 4'h0; b = 4'h0;
            end
            // Draw cursor
            if(cell==cursor && ((x%213<5)||(x%213>208)||(y%160<5)||(y%160>155))) begin
                r = 4'hF; g = 4'hF; b = 4'hF; // WHITE
            end
        end else begin
            r = 4'b0;
            g = 4'b0;
            b = 4'b0;
        end
    end


    always @(*) begin 
        VGA_R=r; VGA_G=g; VGA_B=b; 
    end
endmodule
