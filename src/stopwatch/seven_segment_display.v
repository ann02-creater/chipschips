`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// 7세그먼트 디스플레이 컨트롤러 모듈 (7-Segment Display Controller)
//
// 기능: 시간 데이터를 8자리 7세그먼트 디스플레이에 표시
// - 시분할 주사 방식으로 8개 디지트 제어
// - MM:SS.CC 형식으로 시간 표시 (분:초.센티초)
// - Common Anode 타입 7세그먼트 지원
//
// 디스플레이 형식:
// [7] [6] [5] [4] [3] [2] [1] [0]
//  M   M   :   S   S   .   C   C
//  분  분  콜론 초  초  점  센티 센티
//
// 주사 주파수: 약 8kHz (각 디지트당 1kHz = 사람 눈에는 연속으로 보임)
//////////////////////////////////////////////////////////////////////////////////

module seven_segment_display(
    input wire clk,                 // 시스템 클럭 (100MHz)
    input wire clk_refresh,         // 디스플레이 주사 클럭 (8kHz)
    input wire rst_n,               // 비동기 리셋 (active low)
    input wire [5:0] minutes,       // 분 입력 (0~59)
    input wire [5:0] seconds,       // 초 입력 (0~59)
    input wire [6:0] centiseconds,  // 센티초 입력 (0~99)
    output reg [6:0] seg,           // 7세그먼트 출력 (a,b,c,d,e,f,g)
    output reg [7:0] an             // 디지트 enable (active low)
);

    // ========== 내부 신호 선언 ==========
    
    // 디지트 선택 및 주사 제어
    reg [2:0] digit_select;         // 현재 표시할 디지트 (0~7)
    reg clk_refresh_prev;           // 주사 클럭 edge detection용
    wire clk_refresh_edge;          // 주사 클럭 rising edge
    
    // BCD 변환된 각 자릿수
    reg [3:0] minutes_tens;         // 분의 십의 자리 (0~5)
    reg [3:0] minutes_ones;         // 분의 일의 자리 (0~9)
    reg [3:0] seconds_tens;         // 초의 십의 자리 (0~5)
    reg [3:0] seconds_ones;         // 초의 일의 자리 (0~9)
    reg [3:0] centiseconds_tens;    // 센티초의 십의 자리 (0~9)
    reg [3:0] centiseconds_ones;    // 센티초의 일의 자리 (0~9)
    
    // 현재 디지트의 BCD 값
    reg [3:0] current_bcd;          // 현재 표시 중인 디지트의 BCD 값
    
    // 7세그먼트 패턴 (Common Anode, Active Low)
    reg [6:0] seg_pattern;          // 7세그먼트 패턴 룩업 결과
    
    // ========== 주사 클럭 Edge Detection ==========
    // 주사 클럭의 상승 에지를 감지하여 디지트 전환 타이밍 생성
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_refresh_prev <= 1'b0;
        end else begin
            clk_refresh_prev <= clk_refresh;
        end
    end
    
    assign clk_refresh_edge = clk_refresh & ~clk_refresh_prev;
    
    // ========== BCD 변환 로직 ==========
    // 각 시간 단위를 십의 자리와 일의 자리로 분리
    always @(*) begin
        // 분 BCD 변환 (0~59 -> 십의자리 0~5, 일의자리 0~9)
        minutes_tens = minutes / 10;    // 나눗셈으로 십의 자리 추출
        minutes_ones = minutes % 10;    // 나머지로 일의 자리 추출
        
        // 초 BCD 변환 (0~59 -> 십의자리 0~5, 일의자리 0~9)  
        seconds_tens = seconds / 10;
        seconds_ones = seconds % 10;
        
        // 센티초 BCD 변환 (0~99 -> 십의자리 0~9, 일의자리 0~9)
        centiseconds_tens = centiseconds / 10;
        centiseconds_ones = centiseconds % 10;
    end
    
    // ========== 디지트 주사 제어 ==========
    // 8개 디지트를 순차적으로 빠르게 점등하여 모든 숫자가 동시에 보이도록 구현
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            digit_select <= 3'd0;      // 가장 오른쪽 디지트부터 시작
        end else if (clk_refresh_edge) begin
            // 주사 클럭마다 다음 디지트로 이동 (0->1->2->...->7->0)
            digit_select <= digit_select + 1;  // 3비트이므로 자동으로 0~7 순환
        end
    end
    
    // ========== 현재 디지트 BCD 값 선택 ==========
    // 현재 선택된 디지트에 해당하는 BCD 값을 출력
    always @(*) begin
        case (digit_select)
            3'd0: current_bcd = centiseconds_ones;  // 가장 오른쪽: 센티초 일의 자리
            3'd1: current_bcd = centiseconds_tens;  // 센티초 십의 자리
            3'd2: current_bcd = 4'hF;               // 소수점 위치 (빈칸 또는 점)
            3'd3: current_bcd = seconds_ones;       // 초 일의 자리
            3'd4: current_bcd = seconds_tens;       // 초 십의 자리
            3'd5: current_bcd = 4'hF;               // 콜론 위치 (빈칸 또는 :)
            3'd6: current_bcd = minutes_ones;       // 분 일의 자리
            3'd7: current_bcd = minutes_tens;       // 가장 왼쪽: 분 십의 자리
            default: current_bcd = 4'h0;           // 기본값
        endcase
    end
    
    // ========== 7세그먼트 디코더 (BCD to 7-Segment) ==========
    // BCD 값을 7세그먼트 패턴으로 변환
    // Common Anode 타입: 0 = LED 켜짐, 1 = LED 꺼짐
    always @(*) begin
        case (current_bcd)
            4'h0: seg_pattern = 7'b1000000;    // "0" - 0번 세그먼트만 꺼짐 (가운데)
            4'h1: seg_pattern = 7'b1111001;    // "1" - b,c만 켜짐 (오른쪽 세로 두 개)
            4'h2: seg_pattern = 7'b0100100;    // "2" - a,b,g,e,d 켜짐
            4'h3: seg_pattern = 7'b0110000;    // "3" - a,b,g,c,d 켜짐
            4'h4: seg_pattern = 7'b0011001;    // "4" - f,g,b,c 켜짐
            4'h5: seg_pattern = 7'b0010010;    // "5" - a,f,g,c,d 켜짐
            4'h6: seg_pattern = 7'b0000010;    // "6" - a,f,g,e,d,c 켜짐
            4'h7: seg_pattern = 7'b1111000;    // "7" - a,b,c 켜짐
            4'h8: seg_pattern = 7'b0000000;    // "8" - 모든 세그먼트 켜짐
            4'h9: seg_pattern = 7'b0010000;    // "9" - a,b,c,d,f,g 켜짐
            4'hA: seg_pattern = 7'b0001000;    // "A" - a,b,c,e,f,g 켜짐
            4'hB: seg_pattern = 7'b0000011;    // "b" - c,d,e,f,g 켜짐
            4'hC: seg_pattern = 7'b1000110;    // "C" - a,d,e,f 켜짐
            4'hD: seg_pattern = 7'b0100001;    // "d" - b,c,d,e,g 켜짐
            4'hE: seg_pattern = 7'b0000110;    // "E" - a,d,e,f,g 켜짐
            4'hF: seg_pattern = 7'b1111111;    // 빈칸 - 모든 세그먼트 꺼짐
            default: seg_pattern = 7'b1111111; // 기본값: 빈칸
        endcase
    end
    
    // ========== 디지트 Enable 신호 생성 ==========
    // 현재 선택된 디지트만 활성화 (Active Low)
    // 예: digit_select = 0일 때, an = 8'b11111110 (0번 디지트만 활성화)
    always @(*) begin
        an = 8'b11111111;              // 기본값: 모든 디지트 비활성화
        an[digit_select] = 1'b0;       // 현재 디지트만 활성화 (Active Low)
    end
    
    // ========== 최종 출력 ==========
    // 계산된 7세그먼트 패턴을 출력
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            seg <= 7'b1111111;         // 리셋 시 모든 세그먼트 꺼짐
        end else begin
            seg <= seg_pattern;        // 계산된 패턴 출력
        end
    end
    
    // ========== 특수 문자 처리 (선택사항) ==========
    // 콜론(:)이나 소수점(.) 표시를 위한 추가 로직
    // NEXYS A7 보드에 DP(Decimal Point) 핀이 있다면 활용 가능
    
    // synthesis translate_off  // 시뮬레이션 전용 코드 시작
    
    // 디스플레이 상태 모니터링 (디버깅용)
    always @(posedge clk) begin
        if (clk_refresh_edge) begin
            $display("[%t] Digit %d: BCD=%h, Pattern=%b, AN=%b", 
                     $time, digit_select, current_bcd, seg_pattern, an);
        end
    end
    
    // 시간 변화 감지 및 출력
    reg [5:0] prev_seconds;
    always @(posedge clk) begin
        if (seconds != prev_seconds) begin
            $display("[%t] 디스플레이 시간 업데이트: %02d:%02d.%02d", 
                     $time, minutes, seconds, centiseconds);
            prev_seconds <= seconds;
        end
    end
    
    // synthesis translate_on   // 시뮬레이션 전용 코드 끝

endmodule