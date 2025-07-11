module scan_gen(
    input wire clk,
    input wire reset,
    output reg HS, VS,
    output wire video_on,
    output reg [9:0] x, y
);

    localparam H_DISPLAY=640, H_FRONT=16, H_SYNC=96, H_BACK=48, H_TOTAL=800;
    localparam V_DISPLAY=480, V_FRONT=10, V_SYNC=2, V_BACK=33, V_TOTAL=525;

    always @(posedge clk or posedge reset) begin
        if (reset)
            x <= 0;
        else if (x == H_TOTAL - 1)
            x <= 0;
        else
            x <= x + 1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            y <= 0;
        else if (x == H_TOTAL - 1) begin
            if (y == V_TOTAL - 1)
                y <= 0;
            else
                y <= y + 1;
        end
    end

    always @(*) begin
        HS = ~((x >= H_DISPLAY + H_FRONT) && (x < H_DISPLAY + H_FRONT + H_SYNC));
        VS = ~((y >= V_DISPLAY + V_FRONT) && (y < V_DISPLAY + V_FRONT + V_SYNC));
    end

    assign video_on = (x < H_DISPLAY) && (y < V_DISPLAY);

endmodule