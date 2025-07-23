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
    localparam H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;

    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    always @(posedge clk or posedge reset) begin
        if (reset)
            x <= 0;
        else if (x == H_TOTAL-1)
            x <= 0;
        else
            x <= x + 1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            y <= 0;
        else if (x == H_TOTAL-1) begin
            if (y == V_TOTAL-1)
                y <= 0;
            else
                y <= y + 1;
        end
    end

    always @(*) begin
        hsync = ~((x >= H_VISIBLE + H_FRONT) &&
                  (x <  H_VISIBLE + H_FRONT + H_SYNC));
        vsync = ~((y >= V_VISIBLE + V_FRONT) &&
                  (y <  V_VISIBLE + V_FRONT + V_SYNC));
        en    = (x < H_VISIBLE) && (y < V_VISIBLE);
    end

endmodule
