`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// 스톱워치 카운터 모듈 (Stopwatch Counter Module)
//
// 기능: 시간을 정확히 계산하고 저장하는 핵심 로직
// - 센티초(0.01초) 단위로 정밀한 시간 측정
// - Start/Stop/Reset 제어 신호 처리
// - 59분 59초 99센티초까지 카운트 (3599.99초)
//
// 시간 형식: MM:SS.CC (분:초.센티초)
// - 센티초: 00~99 (0.01초 단위)
// - 초: 00~59
// - 분: 00~59
//////////////////////////////////////////////////////////////////////////////////

module stopwatch_counter(
    input wire clk,                 // 시스템 클럭 (100MHz)
    input wire clk_1ms,             // 1ms 타이밍 클럭
    input wire rst_n,               // 비동기 리셋 (active low)
    input wire start_edge,          // Start/Stop 버튼 눌림 (1 클럭 펄스)
    input wire reset_edge,          // Reset 버튼 눌림 (1 클럭 펄스)
    output reg running,             // 스톱워치 동작 상태 (1: 동작, 0: 정지)
    output reg [6:0] centiseconds,  // 센티초 (0~99)
    output reg [5:0] seconds,       // 초 (0~59)  
    output reg [5:0] minutes        // 분 (0~59)
);

    // ========== 내부 신호 선언 ==========
    
    // 1ms 클럭 edge detection용
    reg clk_1ms_prev;               // 이전 1ms 클럭 상태
    wire clk_1ms_edge;              // 1ms 클럭 rising edge
    
    // 시간 카운터용 임시 변수 (오버플로우 처리용)
    reg [6:0] next_centiseconds;    // 다음 센티초 값
    reg [5:0] next_seconds;         // 다음 초 값  
    reg [5:0] next_minutes;         // 다음 분 값
    
    // ========== 1ms 클럭 Edge Detection ==========
    // 1ms 클럭의 상승 에지를 감지하여 정확한 카운팅 타이밍 생성
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_1ms_prev <= 1'b0;
        end else begin
            clk_1ms_prev <= clk_1ms;
        end
    end
    
    assign clk_1ms_edge = clk_1ms & ~clk_1ms_prev;  // Rising edge 감지
    
    // ========== 스톱워치 상태 제어 로직 ==========
    // Start/Stop 버튼과 Reset 버튼에 따른 동작 상태 제어
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 하드웨어 리셋 시 정지 상태로 초기화
            running <= 1'b0;
        end else if (reset_edge) begin
            // Reset 버튼이 눌리면 무조건 정지
            running <= 1'b0;
        end else if (start_edge) begin
            // Start/Stop 버튼이 눌리면 상태 토글
            running <= ~running;    // 0->1 (시작) 또는 1->0 (정지)
        end
        // 그 외의 경우는 현재 상태 유지
    end
    
    // ========== 시간 카운터 증가 로직 ==========
    // 1ms마다 센티초를 증가시키고, 오버플로우 시 상위 단위 증가
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 하드웨어 리셋 시 모든 시간을 0으로 초기화
            centiseconds <= 7'd0;
            seconds <= 6'd0;
            minutes <= 6'd0;
        end else if (reset_edge) begin
            // Reset 버튼이 눌리면 모든 시간을 0으로 초기화
            centiseconds <= 7'd0;
            seconds <= 6'd0;
            minutes <= 6'd0;
        end else if (running && clk_1ms_edge) begin
            // 스톱워치가 동작 중이고 1ms가 지났을 때만 시간 증가
            
            // ===== 센티초 처리 (0~99) =====
            if (centiseconds >= 7'd99) begin
                // 센티초가 99에 도달하면 0으로 리셋하고 초 증가
                centiseconds <= 7'd0;
                
                // ===== 초 처리 (0~59) =====
                if (seconds >= 6'd59) begin
                    // 초가 59에 도달하면 0으로 리셋하고 분 증가
                    seconds <= 6'd0;
                    
                    // ===== 분 처리 (0~59) =====
                    if (minutes >= 6'd59) begin
                        // 59분 59초 99센티초에 도달하면 전체 리셋
                        // (99시간 대신 59분에서 리셋으로 설계)
                        minutes <= 6'd0;
                    end else begin
                        // 분 증가
                        minutes <= minutes + 1;
                    end
                end else begin
                    // 초 증가
                    seconds <= seconds + 1;
                end
            end else begin
                // 센티초 증가 (가장 일반적인 경우)
                centiseconds <= centiseconds + 1;
            end
        end
        // running이 0이면 시간 증가하지 않음 (정지 상태)
    end
    
    // ========== 조합 로직으로 다음 값 미리 계산 (선택사항) ==========
    // 시뮬레이션이나 디버깅을 위해 다음에 올 값을 미리 계산
    // 실제 합성에서는 최적화로 제거될 수 있음
    always @(*) begin
        // 기본값은 현재 값
        next_centiseconds = centiseconds;
        next_seconds = seconds;
        next_minutes = minutes;
        
        if (running) begin
            // 다음 센티초 계산
            if (centiseconds >= 7'd99) begin
                next_centiseconds = 7'd0;
                
                // 다음 초 계산
                if (seconds >= 6'd59) begin
                    next_seconds = 6'd0;
                    
                    // 다음 분 계산
                    if (minutes >= 6'd59) begin
                        next_minutes = 6'd0;  // 전체 리셋
                    end else begin
                        next_minutes = minutes + 1;
                    end
                end else begin
                    next_seconds = seconds + 1;
                end
            end else begin
                next_centiseconds = centiseconds + 1;
            end
        end
    end
    
    // ========== 상태 모니터링 (디버깅용) ==========
    // synthesis translate_off  // 시뮬레이션 전용 코드 시작
    
    // 스톱워치 상태 변화 감지 및 로그 출력
    always @(posedge clk) begin
        if (start_edge) begin
            $display("[%t] 스톱워치 상태 변경: %s -> %s", 
                     $time, 
                     running ? "STOP" : "RUN", 
                     running ? "RUN" : "STOP");
        end
        
        if (reset_edge) begin
            $display("[%t] 스톱워치 리셋 실행", $time);
        end
        
        // 1초마다 현재 시간 출력 (센티초가 0일 때)
        if (running && clk_1ms_edge && centiseconds == 7'd0) begin
            $display("[%t] 현재 시간: %02d:%02d.%02d", 
                     $time, minutes, seconds, centiseconds);
        end
    end
    
    // synthesis translate_on   // 시뮬레이션 전용 코드 끝

endmodule