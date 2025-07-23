module key_decoder (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  data,
    input  wire        valid,
    output reg         up,
    output reg         down,
    output reg         left,
    output reg         right,
    output reg         enter,
    output reg         space
);

    localparam W_ASCII     = 8'h57;
    localparam A_ASCII     = 8'h41;
    localparam S_ASCII     = 8'h53;
    localparam D_ASCII     = 8'h44;
    localparam ENTER_ASCII = 8'h0D;
    localparam SPACE_ASCII = 8'h20;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            up    <= 0; down  <= 0;
            left  <= 0; right <= 0;
            enter <= 0; space <= 0;
        end else begin
            up    <= 0; down  <= 0;
            left  <= 0; right <= 0;
            enter <= 0; space <= 0;
            if (valid) begin
                case (data)
                    W_ASCII:     up    <= 1;
                    S_ASCII:     down  <= 1;
                    A_ASCII:     left  <= 1;
                    D_ASCII:     right <= 1;
                    ENTER_ASCII: enter <= 1;
                    SPACE_ASCII: space <= 1;
                    default: ;
                endcase
            end
        end
    end
endmodule