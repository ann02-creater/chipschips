module circle_ram #(
  parameter WIDE       = 213,
  parameter HIGH       = 160,
  parameter ADDR_WIDTH = 16,
  parameter R          = 60,
  parameter T          = 5
)(
  input  wire        clk,
  input  wire        reset,
  input  wire        rd_en,
  input  wire [15:0] rd_addr,
  output wire        rd_data,
  output reg         init_done
);

  reg [15:0] wr_addr;
  reg        W_en;
  reg        W_data;

  localparam CX = WIDE/2;
  localparam CY = HIGH/2;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      wr_addr   <= 0;
      init_done <= 1'b0;
      W_en       <= 1'b1;
    end else if (!init_done) begin
      if (wr_addr == WIDE*HIGH - 1) begin
        init_done <= 1'b1;
        wea       <= 1'b0;
      end else begin
        wr_addr <= wr_addr + 1;
      end
    end
  end

  wire [16:0] row    = wr_addr / WIDE;
  wire [16:0] col    = wr_addr % WIDE;
  wire signed [15:0] dx = col - CX;
  wire signed [15:0] dy = row - CY;
  wire [33:0]     dist2  = dx*dx + dy*dy;
  wire is_edge = (dist2 >= (R-T)*(R-T)) && (dist2 <= R*R);

  always @(*) begin
    if (!init_done)
      W_data = is_edge;
    else
      W_data = 1'b0;
  end

  blk_mem_gen_0 bram (
    .clka  (clk),
    .ena   (W_en | rd_en),
    .wea   (W_en),
    .addra (W_en ? wr_addr : rd_addr),
    .dina  (rd_data),
    .douta (W_data)
  );

endmodule
