module control(
  input wire clk, reset,
  input wire en, store, load,
  output reg write, select
);

    // State encoding
    localparam IDLE = 3'b000
              , RUN = 3'b001
              , STOP = 3'b010
              , SAVE = 3'b011
              , SHOW = 3'b100; 
            
    reg [2:0] current_state, next_state;

    // State Memory : 클록 엣지마다 현재 상태를 업데이트하는 역할
    always@(posedge clk, posedge reset) begin
        if(reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end
  
    // Next State Logic
    always @(*) begin
        case(current_state)
            IDLE: if(en) next_state = RUN;
                  else next_state = IDLE;
             RUN: if(en) next_state = RUN;
                  else next_state = STOP;
            STOP: if(en && !store && !load) next_state = RUN;
                  else if(!en && !store && !load) next_state = STOP;
                  else if(!en && !store && load) next_state = SHOW;
                  else if(!en && store && !load) next_state = SAVE;
                  else next_state = STOP; 
            SAVE: next_state = STOP;
            SHOW: if(en) next_state = RUN;
                  else next_state = SHOW;
            default: next_state = IDLE;
        endcase
    end

    // Output Logic
    always @(*) begin
        case(current_state)
            IDLE: begin write = 0; select = 0; end
            RUN: begin write = 0; select = 0; end
            STOP: begin write = 0; select = 0; end
            SAVE: begin write = 1; select = 0; end
            SHOW: begin write = 0; select = 1; end
            default: begin write = 0; select = 0; end
        endcase
    end

endmodule


