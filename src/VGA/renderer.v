module renderer(
    input wire [9:0] x, y,
    input wire video_on,
    input wire [8:0] board,
    input wire [3:0] cursor,
    output reg [3:0] VGA_R, VGA_G, VGA_B
);
    localparam BLACK=12'b0000_0000_0000, RED=12'b1111_0000_0000, GREEN=12'b0000_1111_0000, WHITE=12'b1111_1111_1111;
    reg [3:0] r,g,b;
    integer cell_x, cell_y, cell;

    // Define the color for each cell
    always @(*) begin
        if(video_on) begin
            integer cell_x = x / 213;
            integer cell_y = y / 160;
            integer cell = cell_y*3+cell_x;
            if(board[cell]==1) {r,g,b}=RED;
            else if(board[cell]==2) {r,g,b}=GREEN;
            else {r,g,b}=BLACK;
            if(cell==cursor && ((x%213<3)||(x%213>210)||(y%160<3)||(y%160>157))) {r,g,b}=WHITE;
        end else {r,g,b}=0;
    end

// Assign the color to VGA output
    always @(*) begin 
        VGA_R=r; VGA_G=g; VGA_B=b; 
    end
endmodule