module vga_sync(
    input  wire       clk,
    input  wire       reset,
    output reg  [9:0] x,//가로칸 799
    output reg  [9:0] y,//세로칸 524
    output reg        hsync,//수평 동기 신호
    output reg        vsync,//수직 동기 신호
    output reg        en
);

    localparam H_VISIBLE = 640;      //VISIBLE = 눈에 보이는 픽셀 수        
    localparam H_FRONT   = 16;       // 보이는 영역이 끝난 후 동기화 펄스까지 여백        
    localparam H_SYNC    = 96;       // 동기화 펄스의 길이   
    localparam H_BACK    = 48;       // 동기화 펄스가 끝난 후 다음 줄 시작전까지 여백      
    localparam H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK-1;

    localparam V_VISIBLE = 480;              
    localparam V_FRONT   = 10;                
    localparam V_SYNC    = 2;                
    localparam V_BACK    = 33;               
    localparam V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK-1;  



    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x <= 0;
            y <= 0;
        end else begin
            if (x == H_TOTAL) begin
                x <= 0;
                y <= (y == V_TOTAL) ? 0 : y + 1;//가로가 끝나면 세로줄 증가, 가로줄 리셋
            end else begin
                x <= x + 1;//아니면 가로줄 증가
            end
        end
    end

    always @(*) begin
        
        hsync   = ~((x >= H_VISIBLE + H_FRONT) &&
                    (x <  H_VISIBLE + H_FRONT + H_SYNC));
       
        vsync   = ~((y >= V_VISIBLE + V_FRONT) &&
                    (y <  V_VISIBLE + V_FRONT + V_SYNC));
       
        en = (x < H_VISIBLE) && (y < V_VISIBLE);//화면에 표시되는 영역인지 확인
    end
endmodule
