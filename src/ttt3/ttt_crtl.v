module ttt_crtl (
    input  wire        clk,
    input  wire        reset,
    input  wire        up,
    input  wire        down,
    input  wire        left,
    input  wire        right,
    input  wire        enter,
    input  wire        space,
    output reg  [3:0]  current_cell,
    output reg  [8:0]  cell_select_flag,

    output reg  [8:0]  board_out1,
    output reg  [8:0]  board_out2,
    output reg         turn
);

  localparam S_MOVE  = 2'b00,
             S_WAIT  = 2'b01,
             S_PLACE = 2'b10;

  reg [1:0] state;
  reg [8:0] board_p1, board_p2;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state            <= S_MOVE;
      current_cell     <= 4'd0;
      cell_select_flag <= 9'b000_000_001;
      board_p1         <= 9'b0;
      board_p2         <= 9'b0;
      turn             <= 1'b0;
    end else begin
      case (state)
        S_MOVE: begin
          if (space_edge && !(board_p1[current_cell] | board_p2[current_cell]))
            state <= S_WAIT;
        end

        S_WAIT: begin
          if (enter_edge)
            state <= S_PLACE;
          else if (space_edge)
            state <= S_MOVE;
        end

        S_PLACE: begin
          if (turn == 1'b0)
            board_p1[current_cell] <= 1'b1;
          else
            board_p2[current_cell] <= 1'b1;

          turn  <= ~turn;
          state <= S_MOVE;
        end

        default: state <= S_MOVE;
      endcase
    end
  end

  always @(*) begin
    board_out1 = board_p1;
    board_out2 = board_p2;
  end

endmodule
