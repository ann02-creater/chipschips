module clock_module(
    input wire clk_in,
    output wire clk_out
);
wire locked;
wire clk_100MHz;

baudrate_gen u1(.clk(clk_100MHz), .clk1(clk_out));
endmodule

module baudrate_gen(
    input wire clk, reset,
    output reg clk1
);
reg [27:0] counter;

always @(posedge clk, posedge reset)begin
    if(reset)
        counter <= 0;
    else if(counter == 10417)
        counter <= 28'b0;
    else
        counter <= counter + 1'b1;
end

always @(posedge clk, posedge reset)begin
    if(reset)
        clk1 <= 0;
    else if (counter == 0)
        clk1 <= 1'b0;
    else if(counter == 5208)
        clk1 <= ~clk1;
    else if(counter == 10417)
        clk1 <= ~clk1;
end

endmodule
