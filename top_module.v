`timescale 1ns / 1ps

module top_module(
    input [16:1] SW,      // 16 switches
    output a,
    output b,
    output c,
    output d,
    output e,
    output f,
    output g,
    output dp
);

// Internal signals
wire [2:0] mux_out;

// Switch mapping according to specification:
// SW[16:15] - Input A [2:0]
// SW[14:12] - Input B [2:0]
// SW[11:9]  - Input C [2:0]
// SW[8:6]   - Input D [2:0]
// SW[2:1]   - Selector [1:0]

// Instantiate 3-bit 4-to-1 MUX
mux_4to1_3bit mux_inst(
    .A(SW[16:14]),      // Input A: SW16, SW15, SW14
    .B(SW[13:11]),      // Input B: SW13, SW12, SW11
    .C(SW[10:8]),       // Input C: SW10, SW9, SW8
    .D(SW[7:5]),        // Input D: SW7, SW6, SW5
    .sel(SW[2:1]),      // Selector: SW2, SW1
    .Y(mux_out)
);

// Extend 3-bit output to 4-bit for ss_decoder (add leading zero)
wire [3:0] decoder_input = {1'b0, mux_out};

// Instantiate 7-segment decoder
ss_decoder decoder_inst(
    .Din(decoder_input),
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .e(e),
    .f(f),
    .g(g),
    .dp(dp)
);

endmodule