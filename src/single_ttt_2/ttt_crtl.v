module ttt_practice_ctrl (
    input  wire        clk,
    input  wire        reset,
    input  wire        w,
    input  wire        s,
    input  wire        a,
    input  wire        d,
    input  wire        enter,
    output reg  [8:0]  cursor_pos,
    output reg  [8:0]  board,
    output reg         draw_trigger
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      cursor_pos   <= 9'b100_000_000;
      board        <= 9'b0;
      draw_trigger <= 1'b1;
    end else begin
      draw_trigger <= 1'b0;

      if      (w && (cursor_pos & 9'b111_000_000) != 9'b111_000_000)
        cursor_pos <= cursor_pos >> 3;
      else if (s && (cursor_pos & 9'b000_000_111) != 9'b000_000_111)
        cursor_pos <= cursor_pos << 3;
      else if (a && (cursor_pos & 9'b001_001_001) == 9'b0)
        cursor_pos <= cursor_pos >> 1;
      else if (d && (cursor_pos & 9'b100_100_100) == 9'b0)
        cursor_pos <= cursor_pos << 1;

      if (enter) begin
        board        <= board | cursor_pos;
        draw_trigger <= 1'b1;
      end
    end
  end

endmodule
