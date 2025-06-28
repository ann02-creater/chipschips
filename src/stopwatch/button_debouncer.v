`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// 8비트 시프트 레지스터 버튼 디바운서 모듈 (Button Debouncer Module)
//
// 기능: 기계적 스위치의 바운싱 현상을 제거하여 안정적인 버튼 입력 생성
//
// 동작 원리:
// 1. 1ms마다 버튼 상태를 샘플링하여 8비트 시프트 레지스터에 저장
// 2. 8번 연속으로 같은 값(모두 1 또는 모두 0)이 들어와야 출력 변경
// 3. Rising edge detection으로 버튼이 눌린 순간만 감지
//
// 특징:
// - 8ms의 안정화 시간 (8 × 1ms)
// - 노이즈에 강함 (연속 8번 같은 값이어야 인정)
// - 리소스 효율적 (시프트 레지스터만 사용)
//////////////////////////////////////////////////////////////////////////////////

module button_debouncer(
    input wire clk,             // 시스템 클럭 (100MHz)
    input wire clk_1ms,         // 1ms 샘플링 클럭 
    input wire rst_n,           // 비동기 리셋 (active low)
    input wire btn_in,          // 원시 버튼 입력 (노이즈 포함)
    output reg btn_out,         // 디바운스된 버튼 출력 (안정화됨)
    output wire btn_edge        // 버튼 눌림 순간 감지 (1 클럭 펄스)
);

    // ========== 내부 신호 선언 ==========
    
    // 8비트 시프트 레지스터 - 최근 8개 샘플 저장
    reg [7:0] shift_reg;        // shift_reg[7]: 가장 최근, shift_reg[0]: 가장 오래된 샘플
    
    // 버튼 상태 저장용 레지스터
    reg btn_sync1, btn_sync2;   // 메타스테이블리티 방지용 동기화 플립플롭
    reg btn_stable;             // 안정화된 버튼 상태
    reg btn_prev;               // 이전 클럭의 버튼 상태 (edge detection용)
    
    // 1ms 클럭 edge detection용
    reg clk_1ms_prev;           // 이전 1ms 클럭 상태
    wire clk_1ms_edge;          // 1ms 클럭의 rising edge
    
    // ========== 1ms 클럭 Edge Detection ==========
    // 1ms 클럭의 상승 에지를 감지하여 정확한 샘플링 타이밍 생성
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_1ms_prev <= 1'b0;
        end else begin
            clk_1ms_prev <= clk_1ms;
        end
    end
    
    assign clk_1ms_edge = clk_1ms & ~clk_1ms_prev;  // Rising edge 감지
    
    // ========== 버튼 입력 동기화 ==========
    // 메타스테이블리티를 방지하기 위한 2단계 동기화
    // 비동기 버튼 입력을 시스템 클럭에 동기화
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync1 <= 1'b0;
            btn_sync2 <= 1'b0;
        end else begin
            btn_sync1 <= btn_in;        // 1단계: 원시 입력을 시스템 클럭에 동기화
            btn_sync2 <= btn_sync1;     // 2단계: 메타스테이블리티 완전 제거
        end
    end
    
    // ========== 8비트 시프트 레지스터 디바운싱 ==========
    // 1ms마다 버튼 상태를 샘플링하여 시프트 레지스터에 저장
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // 리셋 시 시프트 레지스터를 0으로 초기화
            shift_reg <= 8'b00000000;
            btn_stable <= 1'b0;
        end else if (clk_1ms_edge) begin  // 1ms마다 샘플링
            // 시프트 레지스터에 새로운 샘플 추가
            // MSB부터 새로운 값이 들어가고, LSB는 버려짐
            shift_reg <= {shift_reg[6:0], btn_sync2};
            
            // 디바운스 로직: 8비트가 모두 같은 값인지 확인
            if (shift_reg == 8'b11111111) begin
                // 8번 연속 '1' -> 버튼이 확실히 눌림
                btn_stable <= 1'b1;
            end else if (shift_reg == 8'b00000000) begin
                // 8번 연속 '0' -> 버튼이 확실히 떨어짐  
                btn_stable <= 1'b0;
            end
            // 그 외의 경우 (중간 상태)는 이전 상태 유지
        end
    end
    
    // ========== 출력 및 Edge Detection ==========
    // 안정화된 버튼 상태를 출력하고, 눌림 순간을 감지
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_out <= 1'b0;
            btn_prev <= 1'b0;
        end else begin
            btn_out <= btn_stable;      // 안정화된 상태를 출력
            btn_prev <= btn_stable;     // 다음 클럭을 위해 현재 상태 저장
        end
    end
    
    // 버튼 눌림 순간 감지 (Rising Edge Detection)
    // 이전 클럭에서는 0이었고, 현재 클럭에서 1인 경우
    assign btn_edge = btn_stable & ~btn_prev;
    
    // ========== 디버깅 및 시뮬레이션용 신호들 ==========
    // 시뮬레이션에서 내부 동작을 관찰하기 위한 신호들
    // 실제 합성에서는 최적화로 제거될 수 있음
    
    // synthesis translate_off  // 시뮬레이션 전용 코드 시작
    reg [3:0] stable_count;     // 연속으로 안정한 상태가 지속된 횟수
    
    always @(posedge clk) begin
        if (clk_1ms_edge) begin
            if (shift_reg == 8'b11111111 || shift_reg == 8'b00000000) begin
                stable_count <= (stable_count < 4'd15) ? stable_count + 1 : stable_count;
            end else begin
                stable_count <= 4'd0;
            end
        end
    end
    // synthesis translate_on   // 시뮬레이션 전용 코드 끝

endmodule