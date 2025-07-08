module clock_module(
    input wire clk_in,
    output wire clk_out
);
wire locked;
wire clk_100MHz;

baudrate_gen u1(.clk(clk_100MHz), .clk1(clk_out));
endmodule

module baudrate_gen(
    input wire clk,
    output reg clk1
);
reg [27:0] counter = 28'b0;

always @(posedge clk)begin
    if(counter == 867)
        counter <= 28'b0;
    else
        counter <= counter + 1'b1;
end

always @(posedge clk)begin
    if (counter == 0)
        clk1 <= 1'b0;
    else if(counter == 434)
        clk1 <= ~clk1;
    else if(counter == 867)
        clk1 <= ~clk1;
end

endmodule
