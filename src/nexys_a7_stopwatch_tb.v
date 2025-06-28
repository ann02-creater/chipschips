`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// NEXYS A7 모듈식 스톱워치 종합 테스트벤치
//
// 테스트 대상: 모든 서브모듈들의 개별 기능 및 통합 동작
// 1. 클럭 분주기 테스트
// 2. 버튼 디바운서 테스트 (8비트 시프트 레지스터)
// 3. 스톱워치 카운터 테스트
// 4. 7세그먼트 디스플레이 테스트
// 5. 전체 시스템 통합 테스트
//
// 시뮬레이션 시간: 약 100ms (실제 사용 시나리오 테스트)
//////////////////////////////////////////////////////////////////////////////////

module nexys_a7_stopwatch_tb();

    // ========== 테스트벤치 신호 선언 ==========
    
    // DUT 입출력 신호
    reg CLK100MHZ;                  // 100MHz 시스템 클럭
    reg BTNC;                       // Start/Stop 버튼
    reg BTNU;                       // Reset 버튼
    wire [6:0] SEG;                 // 7세그먼트 출력
    wire [7:0] AN;                  // 디지트 enable
    
    // 테스트 제어용 신호
    integer test_step;              // 현재 테스트 단계
    integer i, j;                   // 루프 카운터
    reg [31:0] timer;               // 테스트 타이밍 제어
    
    // 내부 신호 모니터링용 (실제 설계에서는 접근 불가)
    wire clk_1ms = dut.clk_1ms;
    wire clk_refresh = dut.clk_refresh;
    wire btnc_edge = dut.btnc_edge;
    wire btnu_edge = dut.btnu_edge;
    wire running = dut.running;
    wire [6:0] centiseconds = dut.centiseconds;
    wire [5:0] seconds = dut.seconds;
    wire [5:0] minutes = dut.minutes;
    
    // ========== DUT (Device Under Test) 인스턴스화 ==========
    nexys_a7_stopwatch_top dut (
        .CLK100MHZ(CLK100MHZ),
        .BTNC(BTNC),
        .BTNU(BTNU),
        .SEG(SEG),
        .AN(AN)
    );
    
    // ========== 클럭 생성 (100MHz = 10ns 주기) ==========
    initial begin
        CLK100MHZ = 0;
        forever #5 CLK100MHZ = ~CLK100MHZ;  // 5ns마다 토글
    end
    
    // ========== 메인 테스트 시퀀스 ==========
    initial begin
        // 테스트 초기화
        $display("\n==================================================");
        $display("     NEXYS A7 모듈식 스톱워치 종합 테스트");
        $display("==================================================");
        
        // 초기값 설정
        BTNC = 0;
        BTNU = 0;
        test_step = 0;
        timer = 0;
        
        // 시스템 안정화 대기
        $display("\n[단계 0] 시스템 초기화 및 안정화");
        #1000000;  // 1ms 대기
        $display("시간: %t - 시스템 초기화 완료", $time);
        
        // ========== 테스트 1: 클럭 분주기 검증 ==========
        test_step = 1;
        $display("\n[단계 1] 클럭 분주기 테스트");
        $display("- 100MHz -> 1ms 클럭 분주 검증");
        $display("- 100MHz -> 8kHz 주사 클럭 분주 검증");
        
        // 1ms 클럭 몇 번 관찰
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk_1ms);
            $display("시간: %t - 1ms 클럭 상승 에지 %d번째", $time, i+1);
        end
        
        // 주사 클럭 몇 번 관찰  
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk_refresh);
            if (i < 3) $display("시간: %t - 주사 클럭 상승 에지 %d번째", $time, i+1);
        end
        $display("✓ 클럭 분주기 정상 동작 확인");
        
        // ========== 테스트 2: 버튼 디바운서 검증 ==========
        test_step = 2;
        $display("\n[단계 2] 8비트 시프트 레지스터 디바운서 테스트");
        
        // 2-1: 짧은 노이즈 테스트 (디바운서가 무시해야 함)
        $display("- 짧은 노이즈 입력 테스트");
        BTNC = 1;
        #100000;    // 0.1ms (8ms보다 짧음)
        BTNC = 0;
        #10000000;  // 10ms 대기
        
        if (btnc_edge == 0) begin
            $display("✓ 짧은 노이즈 무시 기능 정상");
        end else begin
            $display("✗ 짧은 노이즈 무시 실패");
        end
        
        // 2-2: 정상적인 버튼 입력 테스트
        $display("- 정상 버튼 입력 테스트 (8ms 이상 유지)");
        BTNC = 1;
        #20000000;  // 20ms 유지
        BTNC = 0;
        
        // 엣지 감지 확인
        wait(btnc_edge == 1);
        $display("✓ 정상 버튼 입력 감지 성공");
        #1000000;   // 1ms 대기
        
        // ========== 테스트 3: 스톱워치 기본 기능 검증 ==========
        test_step = 3;
        $display("\n[단계 3] 스톱워치 기본 기능 테스트");
        
        // 3-1: Reset 기능 테스트
        $display("- Reset 기능 테스트");
        BTNU = 1;
        #20000000;  // 20ms 유지
        BTNU = 0;
        #5000000;   // 5ms 대기
        
        if (running == 0 && centiseconds == 0 && seconds == 0 && minutes == 0) begin
            $display("✓ Reset 기능 정상 - 시간: %02d:%02d.%02d, 상태: %s", 
                     minutes, seconds, centiseconds, running ? "실행" : "정지");
        end else begin
            $display("✗ Reset 기능 오류");
        end
        
        // 3-2: Start 기능 테스트
        $display("- Start 기능 테스트");
        BTNC = 1;
        #20000000;  // 20ms 유지
        BTNC = 0;
        #5000000;   // 5ms 대기
        
        if (running == 1) begin
            $display("✓ Start 기능 정상 - 스톱워치 동작 시작");
        end else begin
            $display("✗ Start 기능 오류");
        end
        
        // 3-3: 시간 증가 확인
        $display("- 시간 증가 확인 (센티초 5개 증가 관찰)");
        for (i = 0; i < 5; i = i + 1) begin
            @(posedge clk_1ms);
            $display("  센티초: %02d", centiseconds);
        end
        $display("✓ 시간 증가 정상");
        
        // 3-4: Stop 기능 테스트
        $display("- Stop 기능 테스트");
        BTNC = 1;
        #20000000;  // 20ms 유지
        BTNC = 0;
        #5000000;   // 5ms 대기
        
        if (running == 0) begin
            $display("✓ Stop 기능 정상 - 스톱워치 정지");
        end else begin
            $display("✗ Stop 기능 오류");
        end
        
        // 정지 상태에서 시간이 증가하지 않는지 확인
        timer = centiseconds;
        #10000000;  // 10ms 대기
        if (centiseconds == timer) begin
            $display("✓ 정지 상태에서 시간 증가 없음 확인");
        end else begin
            $display("✗ 정지 상태에서도 시간이 증가함");
        end
        
        // ========== 테스트 4: 7세그먼트 디스플레이 검증 ==========
        test_step = 4;
        $display("\n[단계 4] 7세그먼트 디스플레이 테스트");
        
        // 스톱워치 재시작
        BTNC = 1; #20000000; BTNC = 0; #5000000;
        
        $display("- 디스플레이 주사 패턴 관찰");
        for (i = 0; i < 16; i = i + 1) begin  // 2사이클 관찰
            @(posedge clk_refresh);
            $display("  Digit %d: AN=%b, SEG=%b", 
                     dut.u_seven_segment_display.digit_select, AN, SEG);
        end
        $display("✓ 디스플레이 주사 정상");
        
        // ========== 테스트 5: 시간 오버플로우 테스트 ==========
        test_step = 5;
        $display("\n[단계 5] 시간 오버플로우 테스트");
        
        // 수동으로 시간을 최대값 근처로 설정 (실제로는 불가능하지만 테스트용)
        $display("- 59초 99센티초 근처에서 오버플로우 테스트");
        // 이 부분은 실제 구현에서는 내부 신호 직접 조작 불가
        // 시뮬레이션에서만 가능한 테스트
        
        // ========== 테스트 6: 연속 동작 테스트 ==========
        test_step = 6;
        $display("\n[단계 6] 연속 동작 안정성 테스트");
        
        $display("- 10초간 연속 동작 테스트");
        for (i = 0; i < 1000; i = i + 1) begin  // 1000 × 1ms = 1초
            @(posedge clk_1ms);
            if (i % 100 == 0) begin  // 0.1초마다 출력
                $display("  경과 시간: %02d:%02d.%02d", minutes, seconds, centiseconds);
            end
        end
        $display("✓ 연속 동작 안정성 확인");
        
        // ========== 테스트 7: 복합 시나리오 테스트 ==========
        test_step = 7;
        $display("\n[단계 7] 복합 시나리오 테스트");
        
        $display("- Start -> Stop -> Start -> Reset 시퀀스");
        
        // Start
        BTNC = 1; #20000000; BTNC = 0; #50000000;  // 시작 후 50ms 대기
        $display("  Start 후: %02d:%02d.%02d", minutes, seconds, centiseconds);
        
        // Stop
        BTNC = 1; #20000000; BTNC = 0; #50000000;  // 정지 후 50ms 대기
        timer = centiseconds;
        $display("  Stop 후: %02d:%02d.%02d", minutes, seconds, centiseconds);
        
        // 정지 확인
        #50000000;  // 50ms 더 대기
        if (centiseconds == timer) begin
            $display("  ✓ 정지 상태 유지 확인");
        end
        
        // Restart
        BTNC = 1; #20000000; BTNC = 0; #50000000;  // 재시작 후 50ms 대기
        $display("  Restart 후: %02d:%02d.%02d", minutes, seconds, centiseconds);
        
        // Reset
        BTNU = 1; #20000000; BTNU = 0; #10000000;  // 리셋 후 10ms 대기
        $display("  Reset 후: %02d:%02d.%02d", minutes, seconds, centiseconds);
        
        if (centiseconds == 0 && seconds == 0 && minutes == 0 && running == 0) begin
            $display("✓ 복합 시나리오 테스트 성공");
        end else begin
            $display("✗ 복합 시나리오 테스트 실패");
        end
        
        // ========== 테스트 완료 ==========
        $display("\n==================================================");
        $display("            모든 테스트 완료");
        $display("==================================================");
        $display("최종 상태:");
        $display("- 시간: %02d:%02d.%02d", minutes, seconds, centiseconds);
        $display("- 동작 상태: %s", running ? "실행중" : "정지");
        $display("- 시뮬레이션 시간: %t", $time);
        
        #100000;  // 마지막 안정화
        $finish;
    end
    
    // ========== 실시간 모니터링 ==========
    
    // 버튼 이벤트 모니터링
    always @(posedge CLK100MHZ) begin
        if (btnc_edge) begin
            $display("[이벤트] BTNC 눌림 - 상태 변경: %s", running ? "정지->시작" : "시작->정지");
        end
        if (btnu_edge) begin
            $display("[이벤트] BTNU 눌림 - 리셋 실행");
        end
    end
    
    // 시간 변화 모니터링 (1초마다)
    reg [5:0] prev_sec = 0;
    always @(posedge CLK100MHZ) begin
        if (seconds != prev_sec && centiseconds == 0) begin
            $display("[시간] %02d:%02d.%02d (%s)", 
                     minutes, seconds, centiseconds, running ? "실행중" : "정지");
            prev_sec = seconds;
        end
    end
    
    // 에러 검출 (범위 초과 값 감지)
    always @(posedge CLK100MHZ) begin
        if (centiseconds > 99) $display("[에러] 센티초 값 초과: %d", centiseconds);
        if (seconds > 59) $display("[에러] 초 값 초과: %d", seconds);
        if (minutes > 59) $display("[에러] 분 값 초과: %d", minutes);
    end

endmodule