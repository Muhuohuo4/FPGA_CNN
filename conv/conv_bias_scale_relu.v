module conv_bias_scale_relu #(
    parameter DATA_WIDTH    = 32,
    parameter BIAS_WIDTH    = 32,
    parameter SCALE_WIDTH   = 16,
    parameter OUT_WIDTH     = 8
)(
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    valid_in,
    input  wire signed [DATA_WIDTH-1:0] sum_in,
    input  wire signed [BIAS_WIDTH-1:0] bias,
    input  wire signed [SCALE_WIDTH-1:0] scale_q8_8,
    output reg  signed [OUT_WIDTH-1:0]  data_out,
    output reg                     valid_out
);

    wire signed [DATA_WIDTH-1:0] biased_sum = sum_in + bias;
    wire signed [2*DATA_WIDTH-1:0] scaled = biased_sum * scale_q8_8;
    wire signed [SCALE_WIDTH-1:0] scaled_q8_8 = scaled[DATA_WIDTH+7:8];

    wire signed [OUT_WIDTH-1:0] relu_out = (scaled_q8_8 > 127)  ? 8'sd127 :
                                 (scaled_q8_8 < 0)    ? 8'sd0   :
                                                        scaled_q8_8[7:0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out  <= 0;
            valid_out <= 0;
        end else begin
            data_out  <= relu_out;
            valid_out <= valid_in;
        end
    end

endmodule
