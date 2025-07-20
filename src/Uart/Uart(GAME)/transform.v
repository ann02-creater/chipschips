module transform (
    input wire clk,
    input wire reset,
    input wire rx_data_valid, // 키보드가 눌렸고 그 데이터가 유효함을 나타냄
    input wire [7:0] rx_data, // 아스키 코드를 전달 받음

    output reg [2:0] cell_move
    output reg place_circle // 동그라미 착수 여부
);


localparam h_visible  = 640;
localparam v_visible = 480;

reg cell_x;
reg cell_y:

always @(posedge clk or posedge reset) begin
    if (reset) begin
        cell_x_move <= 2'd1
        cell_y_move <= 2'd1
        place_circle <= 1'b0;
    end else if (rx_data_valid) begin 
        case (rx_data) begin
            8'h61: begin // a의 아스키코드 (왼쪽으로 이동)
                cell_move <= 3'd1
            end
            8'h64: begin // d의 아스키코드 (오른쪽으로 이동)
                cell_move <= 3'd2;
            end
            8'h77: begin // w의 아스키코드 (위로 이동)
                cell_move <= 3'd3;
            end
            8'h73: begin // s의 아스키코드 (아래로 이동)
                cell_move <= 3'd4;
            end
            8'h20 : begin // space bar의 아스키코드 (동그라미 착수)
                place_circle <= 1'b1; 
            end
            default: begin
               cell_move <= 3'd0; // 아무런 키도 눌리지 않았을 때
            end
            end
        endcase
    end
end

endmodule