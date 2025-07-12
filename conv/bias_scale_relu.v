module bias_scale_relu #(
    parameter DATA_WIDTH    = 32,
    parameter BIAS_WIDTH    = 32,
    parameter SCALE_WIDTH   = 16,
    parameter OUT_WIDTH     = 8
)(
    input  wire                             clk,
    input  wire                             rst,

    // 输入握手
    input  wire                             valid_in,
    input  wire                             ready_in,     // 上游有效，且我能接收
    input  wire signed [DATA_WIDTH-1 :0]    data_in,
    input  wire signed [BIAS_WIDTH-1 :0]    bias,
    input  wire signed [SCALE_WIDTH-1:0]    scale_q8_8,

    // 输出握手
    output reg                              valid_out,
    output wire                             ready_out,    // 下游准备好了
    output reg  signed [OUT_WIDTH-1  :0]    data_out
);

    // 状态：是否持有数据
    reg        has_data;
    reg signed [DATA_WIDTH-1:0]     data_buf;
    reg signed [BIAS_WIDTH-1:0]     bias_buf;
    reg signed [SCALE_WIDTH-1:0]    scale_buf;

    // 握手逻辑
    assign ready_out = !has_data || (has_data && ready_in);

    wire signed [DATA_WIDTH-1  :0] biased_sum   = data_buf + bias_buf;
    wire signed [DATA_WIDTH*2-1:0] scaled       = biased_sum * scale_buf;
    wire signed [SCALE_WIDTH-1 :0] scaled_q8_8  = scaled[DATA_WIDTH+7:8];

    wire signed [OUT_WIDTH-1:0] relu_out =
        (scaled_q8_8 > 127) ? 8'sd127 :
        (scaled_q8_8 < 0)   ? 8'sd0   :
                              scaled_q8_8[7:0];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            has_data  <= 0;
            valid_out <= 0;
            data_out  <= 0;
        end else begin
            // 输入阶段
            if (valid_in && ready_out && !has_data) begin
                data_buf  <= data_in;
                bias_buf  <= bias;
                scale_buf <= scale_q8_8;
                has_data  <= 1;
            end

            // 输出阶段
            if (has_data && ready_in) begin
                data_out  <= relu_out;
                valid_out <= 1;
                has_data  <= 0;
            end else begin
                valid_out <= 0;
            end
        end
    end

endmodule
