module uart_rx(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx_in,
    output reg  [7:0] data_out,
    output reg        data_valid
);

parameter [13:0] CLOCKS_PER_BAUD = 14'd868; // 100MHz / 115200 (표준 설정)

localparam [3:0]
    IDLE  = 4'hF,
    BIT0  = 4'h0,
    BIT1  = 4'h1,
    BIT2  = 4'h2,
    BIT3  = 4'h3,
    BIT4  = 4'h4,
    BIT5  = 4'h5,
    BIT6  = 4'h6,
    BIT7  = 4'h7,
    STOP  = 4'h8;

reg	[3:0]	state;
reg	[13:0]	baud_counter;
reg	zero_baud_counter;
reg q_uart, ck_uart; 

wire [13:0] half_baud = {1'b0, CLOCKS_PER_BAUD[13:1]}; /* [13:0] CLOCKS_PER_BAUD 에서 right shift == /2, MSB = 0 , 5208clocks */

always @(posedge clk)
begin
    q_uart <= rx_in; 
    ck_uart <= q_uart; //메타스테빌리티 위험 방지 동기화과정
end

reg [13:0] chg_counter;
reg half_baud_time;

always @(posedge clk)
    if (q_uart != ck_uart)
        chg_counter <= 14'h0; //카운팅(측정)시작!
    else if (chg_counter < half_baud) //ck_uart =0 이 된 시점부터 카운팅 됨
        chg_counter <= chg_counter + 1;

always @(posedge clk)
    half_baud_time <= (~ck_uart) && (chg_counter >= half_baud); //매클럭마다 신호가 low & half_baud 인지 체크

// Baud counter
always @(posedge clk)
    if (reset) begin
        baud_counter <= 14'h0;
        zero_baud_counter <= 1'b0;
    end 
    else if (state != IDLE) begin
        if (zero_baud_counter)
            baud_counter <= CLOCKS_PER_BAUD - 14'h1; //다음 비트 카운팅 시작
        else
            baud_counter <= baud_counter - 14'h1; //카운팅 중
            zero_baud_counter <= (baud_counter == 14'h1); //0이 되면 다음 비트로 넘어가기 위해 신호 발생
    end 
    else begin // IDLE 상태
        baud_counter <= CLOCKS_PER_BAUD - 14'h1;
        zero_baud_counter <= 1'b0;
    end


always @(posedge clk) // 상태머신
    if (reset)
        state <= IDLE; 
    else if (state == IDLE) begin
        if ((~ck_uart) && half_baud_time)
            state <= BIT0;
    end 
    else if (zero_baud_counter) begin
        if (state < STOP)
            state <= state + 1;
    else
            state <= IDLE;
    end


reg [7:0] data_reg;

always @(posedge clk)
    if (zero_baud_counter)
        data_reg <= {ck_uart, data_reg[7:1]}; //수신된 데이터 비트들을 시프트 레지스터에 저장(BIT0부터 BIT7까지)


always @(posedge clk)
    if (reset) begin
        data_valid <= 1'b0;
        data_out <= 8'h0;

    end else if (zero_baud_counter && (state == STOP)) begin
        data_valid <= 1'b1;
        data_out <= data_reg; // 완성된 8bit 데이터 출력



    end else begin
        data_valid <= 1'b0;
    end

endmodule