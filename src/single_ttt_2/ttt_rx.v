module ttt_rx (
    input  wire       clk_9600,
    input  wire       reset,
    input  wire       rx_data,
    output reg        w, a, s, d,
    output reg        enter,
    output reg        data_valid,
    output reg        parity_error,
    output reg [7:0]  rx_ascii_reg
);

  // FSM state encoding
  localparam
    IDLE   = 3'd0,
    START  = 3'd1,
    DATA   = 3'd2,
    PARITY = 3'd3,
    STOP   = 3'd4;

  reg [2:0] state;
  reg [2:0] bit_cnt;
  reg [7:0] shift_reg;

  always @(posedge clk_9600 or posedge reset) begin
    if (reset) begin
      state         <= IDLE;
      bit_cnt       <= 3'd0;
      shift_reg     <= 8'd0;
      w             <= 1'b0;
      a             <= 1'b0;
      s             <= 1'b0;
      d             <= 1'b0;
      enter         <= 1'b0;
      data_valid    <= 1'b0;
      parity_error  <= 1'b0;
      rx_ascii_reg  <= 8'd0;
    end else begin
      data_valid   <= 1'b0;
      w            <= 1'b0;
      a            <= 1'b0;
      s            <= 1'b0;
      d            <= 1'b0;
      enter        <= 1'b0;

      case (state)
        IDLE: begin
          if (rx_data == 1'b0)
            state <= START;
        end

        START: begin
          state   <= DATA;
          bit_cnt <= 3'd0;
        end

        DATA: begin
          shift_reg[bit_cnt] <= rx_data;
          if (bit_cnt == 3'd7)
            state <= PARITY;
          else
            bit_cnt <= bit_cnt + 1;
        end

        PARITY: begin
          parity_error <= (rx_data != (^shift_reg));
          state        <= STOP;
        end

        STOP: begin
          rx_ascii_reg <= shift_reg;
          if (!parity_error) begin
            data_valid <= 1'b1;
            case (shift_reg)
              8'h77:       w     <= 1'b1;
              8'h61:       a     <= 1'b1;
              8'h73:       s     <= 1'b1;
              8'h64:       d     <= 1'b1;
              8'h0D,8'h0A: enter <= 1'b1;
              default: ;
            endcase
          end
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule
