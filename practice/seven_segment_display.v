`timescale 1ns / 1ps

module seven_segment_display(
    input wire clock,
    input wire clock_refresh,
    input wire reset_n,
    input wire [4:0] hours,
    input wire [5:0] minutes,
    input wire [5:0] seconds,
    input wire [6:0] centiseconds,
    output reg [6:0] seg,
    output reg [7:0] an
);

    reg [2:0] digit_select;
    reg clock_refresh_prev;
    wire clock_refresh_edge;
    
    reg [3:0] hours_tens;
    reg [3:0] hours_ones;
    reg [3:0] minutes_tens;
    reg [3:0] minutes_ones;
    reg [3:0] seconds_tens;
    reg [3:0] seconds_ones;
    reg [3:0] centiseconds_tens;
    reg [3:0] centiseconds_ones;
    
    reg [3:0] current_bcd;
    reg [6:0] seg_pattern;
    
    // TODO: clock_refresh의 rising edge 검출 로직 작성
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            // 리셋 시 이전 클럭 상태 초기화
            clock_refresh_prev <=1'b0;
        end else begin
            // 이전 클럭 상태 저장
            clock_refresh_prev <= clock_refresh;
        end
    end
    
    // TODO: refresh edge 검출 로직 작성
    assign clock_refresh_edge = clock_refresh& ~clock_refresh_prev;
    
    // TODO: 시간 데이터를 BCD(Binary Coded Decimal)로 분리하는 로직 작성
    always @(*) begin
        // hours를 tens와 ones로 분리 (예: 23 -> 2, 3)
        
        hours_tens = hours/10;
        hours_ones = hours%10;
        // minutes를 tens와 ones로 분리 (예: 45 -> 4, 5)
        minutes_tens = minutes/10;
        minutes_ones =minutes%10;
        
        // seconds를 tens와 ones로 분리 (예: 30 -> 3, 0)
        seconds_tens = seconds/10;
        seconds_ones = seconds %10;
        
        // centiseconds를 tens와 ones로 분리 (예: 67 -> 6, 7)
        centiseconds_tens = centiseconds /10;
        centiseconds_ones = centiseconds %10;
        
    end
    
    // TODO: digit 선택 카운터 로직 작성 (0~7 순환)
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            // 리셋 시 digit_select 초기화
            digit_select <=3'b0;
        end else if (clock_refresh_edge) begin
            // refresh edge마다 다음 digit으로 이동
            digit_select <= digit_select +1; 
        end
    end
    
    // TODO: 현재 표시할 digit 선택 로직 작성
    always @(*) begin
        case (digit_select)
            // digit 0: centiseconds ones (가장 오른쪽)
            3'd0: current_bcd = centiseconds_ones;
            // digit 1: centiseconds tens
            3'd1: current_bcd = centiseconds_tens;
            // digit 2: seconds ones
            3'd2: current_bcd = seconds_ones;
            // digit 3: seconds tens
            3'd3: current_bcd = seconds_tens;
            // digit 4: minutes ones
            3'd4: current_bcd = minutes_ones;
            // digit 5: minutes tens
            3'd5: current_bcd = minutes_tens;
            // digit 6: hours ones
            3'd6: current_bcd = hours_ones;
            // digit 7: hours tens (가장 왼쪽)
            3'd7: current_bcd = hours_tens;
            default: current_bcd = 4'h0;
        endcase
    end
    
    // TODO: BCD를 7-segment 패턴으로 변환하는 로직 작성
    always @(*) begin
        case (current_bcd)
            // 숫자 0: a,b,c,d,e,f 켜고 g 끄기
            4'h0: seg_pattern = 7'b1000000;  // 0
            4'h1: seg_pattern = 7'b1111001;  // 1
            4'h2: seg_pattern = 7'b0100100;  // 2
            4'h3: seg_pattern = 7'b0110000;  // 3
            4'h4: seg_pattern = 7'b0011001;  // 4
            4'h5: seg_pattern = 7'b0010010;  // 5
            4'h6: seg_pattern = 7'b0000010;  // 6
            4'h7: seg_pattern = 7'b1111000;  // 7
            4'h8: seg_pattern = 7'b0000000;  // 8
            4'h9: seg_pattern = 7'b0010000;  // 9
            // 나머지는 모든 세그먼트 끄기
            default: seg_pattern = 7'b1111111;
        endcase
    end
    
    // TODO: anode 선택 로직 작성 (multiplexing)
    always @(*) begin
        // 모든 anode를 1로 설정 (비활성화)
        an = 8'b1111111;
        // 현재 선택된 digit만 0으로 설정 (활성화)
        an[digit_select] = 1'b0;
    end
    
    // TODO: 최종 segment 출력 로직 작성
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            // 리셋 시 모든 세그먼트 끄기
            seg <= 7'b1111111;
        end else begin
            // seg_pattern을 출력에 할당
            seg <= seg_pattern;
        end
    end

endmodule