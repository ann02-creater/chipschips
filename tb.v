module tb();
wire out;

reg [3:0] i;
reg [1:0] s;
mux4_1 uut(.out(out),.i(i), .s(s));

initial begin
    {in,s} = 6'b1010_00; 
    #10;
    {in,s} = 6'b1010_01;
    #10;
    {in,s} = 6'b1010_10;
    #10;
    {in,s} = 6'b1010_11;
    #10;
    {in,s} = 6'b1111_00;
    #10;
    {in,s} = 6'b1101_01;
    #10;
    $stop;
end
endmodule