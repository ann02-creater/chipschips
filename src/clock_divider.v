`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// 클럭 분주기 모듈 (Clock Divider Module)
//
// 기능: 100MHz 시스템 클럭을 다양한 주파수로 분주
// - clk_1ms: 1kHz (1ms 주기) - 스톱워치 카운팅용
// - clk_1khz: 1kHz (1ms 주기) - 버튼 디바운싱 샘플링용  
// - clk_refresh: 약 8kHz - 7세그먼트 디스플레이 주사용
//
// 분주 방식: 카운터를 이용한 분주
// 100MHz / 100,000 = 1kHz (1ms)
// 100MHz / 12,500 = 8kHz (0.125ms) 
//////////////////////////////////////////////////////////////////////////////////

module clock_divider(
    input wire clk_100mhz,      // 100MHz 입력 클럭
    input wire rst_n,           // 비동기 리셋 (active low)
    output reg clk_1ms,         // 1ms 클럭 출력 (1kHz)
    output reg clk_refresh      // 디스플레이 주사 클럭 (약 8kHz)
);

    // ========== 내부 신호 선언 ==========
    
    // 1ms 클럭 생성용 카운터 (0 ~ 49,999 카운트 = 50,000개)
    // 100MHz / 50,000 = 2kHz, 토글하면 1kHz
    reg [15:0] counter_1ms;     // 16비트 카운터 (최대 65,535)
    parameter COUNT_1MS = 16'd49999;    // 1ms 생성을 위한 카운트 값
    
    // 디스플레이 주사 클럭 생성용 카운터 (0 ~ 6,249 카운트 = 6,250개)  
    // 100MHz / 6,250 = 16kHz, 토글하면 8kHz
    reg [12:0] counter_refresh; // 13비트 카운터 (최대 8,191)
    parameter COUNT_REFRESH = 13'd6249; // 주사 클럭 생성을 위한 카운트 값
    
    // ========== 1ms 클럭 생성 로직 ==========
    // 목적: 스톱워치의 정확한 타이밍을 위한 1ms 주기 클럭 생성
    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n) begin
            // 리셋 시 초기화
            counter_1ms <= 16'd0;
            clk_1ms <= 1'b0;
        end else begin
            if (counter_1ms >= COUNT_1MS) begin
                // 카운터가 최대값에 도달하면 리셋하고 클럭 토글
                counter_1ms <= 16'd0;
                clk_1ms <= ~clk_1ms;   // 클럭 신호 토글 (0->1 또는 1->0)
            end else begin
                // 카운터 증가
                counter_1ms <= counter_1ms + 1;
            end
        end
    end
    
    // ========== 디스플레이 주사 클럭 생성 로직 ==========
    // 목적: 7세그먼트 디스플레이의 시분할 주사를 위한 빠른 클럭 생성
    // 사람의 눈이 인식하지 못할 정도로 빠르게 각 디지트를 순차 점등
    always @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n) begin
            // 리셋 시 초기화
            counter_refresh <= 13'd0;
            clk_refresh <= 1'b0;
        end else begin
            if (counter_refresh >= COUNT_REFRESH) begin
                // 카운터가 최대값에 도달하면 리셋하고 클럭 토글
                counter_refresh <= 13'd0;
                clk_refresh <= ~clk_refresh;   // 클럭 신호 토글
            end else begin
                // 카운터 증가
                counter_refresh <= counter_refresh + 1;
            end
        end
    end

endmodule