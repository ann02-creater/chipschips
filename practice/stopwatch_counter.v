`timescale 1ns / 1ps

module stopwatch_counter(
    input wire clock,
    input wire clock_1ms,
    input wire reset_n,
    input wire start_edge,
    input wire reset_edge,
    output reg running,
    output reg [6:0] centiseconds,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg [4:0] hours
);
    reg clock_1ms_prev;
    wire clock_1ms_edge;
    
    // TODO: 1ms 클럭의 rising edge 검출을 위한 로직 작성
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            // 리셋 시 이전 클럭 상태 초기화
            clock_1ms_prev <=1'b0;
        end else begin
            // 이전 클럭 상태 저장
            clock_1ms_prev <= clock_1ms;
        end
    end
    
    // TODO: rising edge 검출 로직 (현재 클럭이 1이고 이전 클럭이 0일 때)
    assign clock_1ms_edge = clock_1ms & ~clock_1ms_prev;
    
    // TODO: 스톱워치 실행 상태 제어 로직 작성
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            // 리셋 시 실행 상태 초기화
            running <=1'b0;
        end else if (reset_edge) begin
            // 리셋 버튼 누를 때 실행 상태
            running <=1'b0;
        end else if (start_edge) begin
            // 시작 버튼 누를 때 실행 상태 토글
            running <= ~running;
        end
    end
    
    // TODO: 시간 카운터 로직 작성 (시:분:초.ms 형태)
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            // 리셋 시 모든 시간 초기화
    centiseconds <=7'd0;
    seconds<=6'd0;
    minutes<=6'd0;
    hours<=5'd0;
            
            
            
            
        end else if (reset_edge) begin
            // 리셋 버튼 누를 때 모든 시간 초기화
     centiseconds <=7'd0;
     seconds<=6'd0;
     minutes<=6'd0;
     hours<=5'd0;
            
            
        end else if (running && clock_1ms_edge) begin
            // 실행 중이고 1ms마다 카운터 증가

            if (centiseconds >= 7'd99) begin
                // 99 centiseconds 도달 시 seconds 증가
                centiseconds <= 7'd0;
                
                if (seconds >= 6'd59) begin
                    // 59 seconds 도달 시 minutes 증가
                    seconds <= 6'd0;
                    
                    if (minutes >= 6'd59) begin
                        // 59 minutes 도달 시 hours 증가
                        minutes <=6'd0;
                        if (hours >= 5'd23) begin
                            // 23 hours 도달 시 0으로 리셋 (24시간 형태)
                            hours <= 5'd0;
                        end else begin
                            // hours 증가
                            hours <= hours +1;
                        end
                    end else begin
                        // minutes 증가
                         minutes <= minutes +1;
                    end
                end else begin
                    // seconds 증가
                    seconds <= seconds +1;
                end
            end else begin
                // centiseconds 증가
                centiseconds <= centiseconds +1;
            end
        end
    end

endmodule