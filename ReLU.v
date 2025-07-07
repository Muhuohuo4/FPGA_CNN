module relu #(
    parameter DATA_WIDTH = 32
)(
    input  wire                     clk,
    input  wire                     rst,
    input  wire signed [DATA_WIDTH-1:0] data_in,
    input  wire                     valid_in,
    output reg  signed [DATA_WIDTH-1:0] ReLU_out,
    output reg                      valid_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ReLU_out  <= 0;
            valid_out <= 0;
        end else begin
            if (valid_in) begin
                ReLU_out  <= data_in[DATA_WIDTH-1] ? 0 : data_in;
                valid_out <= 1;
            end else begin
                valid_out <= 0;
            end
        end
    end

endmodule
