module mux4_1(output out, input[3:0] i, input[1:0] s);
wire c0, c1,c2,c3; //컨트롤 신호

assign c0 = ~s[0] & ~s[1];
assign c1 = s[0] & ~s[1];
assign c2 = ~s[0] & s[1];
assign c3 = s[0] & s[1];

bufif1 u0(out, i[0], c0);
bufif1 u1(out, i[1], c1);
bufif1 u2(out, i[2], c2);
bufif1 u3(out, i[3], c3);




endmodule
