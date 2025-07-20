//cell 위치를 계산하여 이동시키는 로직
always @(posedge clk or posedge reset) begin
    if(reset) begin // 처음에 중앙에서 시작한다고 가정
        cell_x <= 1
        cell_y <= 1   
    end else begin
        if (rx_data_valid) begin
            case (cell_move) 
                3'd1: begin // 왼쪽으로 이동
                    if (cell_x > 0) begin
                        cell_x <= cell_x -1;
                    end else begin
                        cell_x <= 0; // 왼쪽 끝에 도달하면 이동하지 않음
                    end
                end
                3'd2: begin // 오른쪽으로 이동
                    if (cell_x < 2) begin
                        cell_x <= cell_x + 1;
                    end else begin
                        cell_x <= 2; // 오른쪽 끝에 도달하면 이동하지 않음
                    end
                end
                3'd3: begin // 위로 이동
                    if (cell_y > 0) begin
                        cell_y <= cell_y -1;
                    end else begin
                        cell_y <= 0; // 위쪽 끝에 도달하면 이동하지 않음
                    end
                end
                3'd4: begin // 아래로 이동
                    if (cell_y < 2) begin
                        cell_y <= cell_y + 1;
                    end else begin
                        cell_y <= 2; // 아래쪽 끝에 도달하면 이동하지 않음
                    end
                end
            endcase
        end
    end
end