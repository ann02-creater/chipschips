`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// NEXYS A7 스톱워치 최상위 모듈 (Top-Level Integration Module)
//
// 기능: 모든 하위 모듈들을 연결하여 완전한 스톱워치 시스템 구성
// - NEXYS A7 보드의 정확한 핀 이름 사용
// - 모듈식 설계로 각 기능별 분리 및 재사용성 확보
// - 체계적인 신호 연결 및 에러 방지
//
// 사용 버튼:
// - BTNC (가운데 버튼): Start/Stop 토글
// - BTNU (위쪽 버튼): Reset
//
// 디스플레이: 8자리 7세그먼트에 MM:SS.CC 형식으로 표시
//////////////////////////////////////////////////////////////////////////////////

module nexys_a7_stopwatch_top(
    // ========== NEXYS A7 보드 핀 연결 ==========
    input wire CLK100MHZ,           // 100MHz 시스템 클럭 (보드 내장)
    input wire BTNC,                // 가운데 버튼 - Start/Stop
    input wire BTNU,                // 위쪽 버튼 - Reset
    output wire [6:0] SEG,          // 7세그먼트 출력 (a~g)
    output wire [7:0] AN            // 8개 디지트 enable (active low)
);

    // ========== 내부 신호 선언 ==========
    
    // 시스템 리셋 신호 (active low)
    wire rst_n;
    assign rst_n = 1'b1;            // 하드웨어 리셋 없음 (버튼 리셋만 사용)
    
    // 클럭 분주기 출력 신호들
    wire clk_1ms;                   // 1ms 클럭 (스톱워치 카운팅용)
    wire clk_refresh;               // 8kHz 클럭 (디스플레이 주사용)
    
    // 디바운서 출력 신호들
    wire btnc_clean;                // 디바운스된 BTNC 신호
    wire btnu_clean;                // 디바운스된 BTNU 신호
    wire btnc_edge;                 // BTNC 눌림 순간 감지
    wire btnu_edge;                 // BTNU 눌림 순간 감지
    
    // 스톱워치 카운터 출력 신호들
    wire running;                   // 스톱워치 동작 상태
    wire [6:0] centiseconds;        // 센티초 (0~99)
    wire [5:0] seconds;             // 초 (0~59)
    wire [5:0] minutes;             // 분 (0~59)
    
    // ========== 모듈 인스턴스화 및 연결 ==========
    
    // ===== 클럭 분주기 모듈 =====
    // 100MHz 시스템 클럭을 필요한 주파수로 분주
    clock_divider u_clock_divider (
        .clk_100mhz(CLK100MHZ),     // 입력: 100MHz 시스템 클럭
        .rst_n(rst_n),              // 입력: 리셋 신호
        .clk_1ms(clk_1ms),          // 출력: 1ms 클럭 (스톱워치용)
        .clk_refresh(clk_refresh)   // 출력: 8kHz 클럭 (디스플레이용)
    );
    
    // ===== Start/Stop 버튼 디바운서 =====
    // BTNC 버튼의 기계적 바운싱을 제거하여 안정적인 입력 생성
    button_debouncer u_btnc_debouncer (
        .clk(CLK100MHZ),            // 입력: 시스템 클럭
        .clk_1ms(clk_1ms),          // 입력: 1ms 샘플링 클럭
        .rst_n(rst_n),              // 입력: 리셋 신호
        .btn_in(BTNC),              // 입력: 원시 버튼 신호
        .btn_out(btnc_clean),       // 출력: 디바운스된 버튼 신호
        .btn_edge(btnc_edge)        // 출력: 버튼 눌림 순간 감지
    );
    
    // ===== Reset 버튼 디바운서 =====
    // BTNU 버튼의 기계적 바운싱을 제거하여 안정적인 입력 생성
    button_debouncer u_btnu_debouncer (
        .clk(CLK100MHZ),            // 입력: 시스템 클럭
        .clk_1ms(clk_1ms),          // 입력: 1ms 샘플링 클럭
        .rst_n(rst_n),              // 입력: 리셋 신호
        .btn_in(BTNU),              // 입력: 원시 버튼 신호
        .btn_out(btnu_clean),       // 출력: 디바운스된 버튼 신호 (사용 안함)
        .btn_edge(btnu_edge)        // 출력: 버튼 눌림 순간 감지
    );
    
    // ===== 스톱워치 카운터 모듈 =====
    // 시간을 정확히 계산하고 Start/Stop/Reset 제어 처리
    stopwatch_counter u_stopwatch_counter (
        .clk(CLK100MHZ),            // 입력: 시스템 클럭
        .clk_1ms(clk_1ms),          // 입력: 1ms 타이밍 클럭
        .rst_n(rst_n),              // 입력: 리셋 신호
        .start_edge(btnc_edge),     // 입력: Start/Stop 버튼 눌림
        .reset_edge(btnu_edge),     // 입력: Reset 버튼 눌림
        .running(running),          // 출력: 스톱워치 동작 상태
        .centiseconds(centiseconds),// 출력: 센티초 (0~99)
        .seconds(seconds),          // 출력: 초 (0~59)
        .minutes(minutes)           // 출력: 분 (0~59)
    );
    
    // ===== 7세그먼트 디스플레이 컨트롤러 =====
    // 시간 데이터를 8자리 7세그먼트 디스플레이에 MM:SS.CC 형식으로 표시
    seven_segment_display u_seven_segment_display (
        .clk(CLK100MHZ),            // 입력: 시스템 클럭
        .clk_refresh(clk_refresh),  // 입력: 디스플레이 주사 클럭
        .rst_n(rst_n),              // 입력: 리셋 신호
        .minutes(minutes),          // 입력: 분 데이터
        .seconds(seconds),          // 입력: 초 데이터
        .centiseconds(centiseconds),// 입력: 센티초 데이터
        .seg(SEG),                  // 출력: 7세그먼트 패턴
        .an(AN)                     // 출력: 디지트 enable 신호
    );
    
    // ========== 시스템 상태 모니터링 (디버깅용) ==========
    // synthesis translate_off  // 시뮬레이션 전용 코드 시작
    
    // 버튼 입력 상태 모니터링
    always @(posedge CLK100MHZ) begin
        if (btnc_edge) begin
            $display("[%t] START/STOP 버튼 눌림 - 상태: %s -> %s", 
                     $time, 
                     running ? "STOP" : "RUN",
                     running ? "RUN" : "STOP");
        end
        
        if (btnu_edge) begin
            $display("[%t] RESET 버튼 눌림 - 시간 초기화", $time);
        end
    end
    
    // 1초마다 현재 상태 출력
    reg [5:0] prev_seconds;
    always @(posedge CLK100MHZ) begin
        if (seconds != prev_seconds) begin
            $display("[%t] 현재 시간: %02d:%02d.%02d (상태: %s)", 
                     $time, minutes, seconds, centiseconds,
                     running ? "실행중" : "정지");
            prev_seconds <= seconds;
        end
    end
    
    // 모듈 간 연결 상태 확인
    initial begin
        $display("=== NEXYS A7 스톱워치 시스템 초기화 ===");
        $display("클럭 분주기: 100MHz -> 1ms, 8kHz");
        $display("버튼 디바운서: 8비트 시프트 레지스터 방식");
        $display("스톱워치: MM:SS.CC 형식, 59:59.99까지 지원");
        $display("디스플레이: 8자리 7세그먼트, 시분할 주사");
        $display("==========================================");
    end
    
    // synthesis translate_on   // 시뮬레이션 전용 코드 끝

endmodule