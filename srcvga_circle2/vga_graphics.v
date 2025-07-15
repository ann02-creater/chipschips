module vga_graphics(
    input  wire [9:0] x,
    input  wire [9:0] y,
    input  wire       en,
    input  wire       sw, // Use switch to turn the circle on/off
    output reg [3:0]  red,
    output reg [3:0]  green,
    output reg [3:0]  blue
);

// Screen dimensions
localparam H_VISIBLE = 640;
localparam V_VISIBLE = 480;

// Circle parameters
localparam CIRCLE_R = 100; // Circle radius
localparam CIRCLE_CX = H_VISIBLE / 2; // Center X
localparam CIRCLE_CY = V_VISIBLE / 2; // Center Y

// Signed values for circle calculation
wire signed [10:0] dx = x - CIRCLE_CX;
wire signed [10:0] dy = y - CIRCLE_CY;
wire in_circle = (dx*dx + dy*dy) < (CIRCLE_R * CIRCLE_R);

always @(*) begin
    if (!en) begin // Screen off, black
        red   = 4'h0;
        green = 4'h0;
        blue  = 4'h0;
    end else if (sw && in_circle) begin // Green circle
        red   = 4'h0;
        green = 4'hF;
        blue  = 4'h0;
    end else begin // Background, white
        red   = 4'hF;
        green = 4'hF;
        blue  = 4'hF;
    end
end

endmodule