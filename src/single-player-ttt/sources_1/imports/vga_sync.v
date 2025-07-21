module vga_sync(
    input  wire       clk,
    input  wire       reset,
    output reg  [9:0] x,
    output reg  [9:0] y,
    output reg        hsync,
    output reg        vsync,
    output reg        en
);

    localparam H_VISIBLE = 640;   
    localparam H_FRONT   = 16;                
    localparam H_SYNC    = 96;              
    localparam H_BACK    = 48;              
    localparam H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK - 1;

    localparam V_VISIBLE = 480;     
    localparam V_FRONT   = 10;                
    localparam V_SYNC    = 2;                
    localparam V_BACK    = 33;               
    localparam V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK - 1;  



    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x <= 0;
            y <= 0;
        end else begin
            if (x == H_TOTAL) begin
                x <= 0;
                y <= (y == V_TOTAL) ? 0 : y + 1;
            end else begin
                x <= x + 1;
            end
        end
    end

    always @(*) begin
        
        hsync   = ~((x >= H_VISIBLE + H_FRONT) &&
                    (x <  H_VISIBLE + H_FRONT + H_SYNC));
       
        vsync   = ~((y >= V_VISIBLE + V_FRONT) &&
                    (y <  V_VISIBLE + V_FRONT + V_SYNC));
       
        en = (x < H_VISIBLE) && (y < V_VISIBLE);
    end
endmodule
