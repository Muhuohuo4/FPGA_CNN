module conv33 #(
    parameter                     DATA_WIDTH = 8,
    parameter                     BIAS_WIDTH = 32,
    parameter                     MUL_WIDTH  = 16,
    parameter                     OUT_WIDTH  = 8
)(
    input  wire                   clk,
    input  wire                   rst,

    // 权重偏置输入
    input  wire [DATA_WIDTH-1:0]  weight_data,
    input  wire [BIAS_WIDTH-1:0]  bias_data,
    input  wire [BIAS_WIDTH-1:0]  scale_data,

    // 输入数据
    input  wire                   input_valid,
    input  wire [DATA_WIDTH-1:0]  in_0_0,
    input  wire [DATA_WIDTH-1:0]  in_0_1,
    input  wire [DATA_WIDTH-1:0]  in_0_2,
    input  wire [DATA_WIDTH-1:0]  in_1_0,
    input  wire [DATA_WIDTH-1:0]  in_1_1,
    input  wire [DATA_WIDTH-1:0]  in_1_2,
    input  wire [DATA_WIDTH-1:0]  in_2_0,
    input  wire [DATA_WIDTH-1:0]  in_2_1,
    input  wire [DATA_WIDTH-1:0]  in_2_2,

    // 卷积结果
    output wire                   out_valid,
    output wire [OUT_WIDTH-1:0]   out_data
);

    // 控制信号
    wire load_weight_en;
    wire read_weight_en;
    wire load_bias_en;
    wire read_bias_en;
    wire load_scale_en;
    wire read_scale_en;
    wire inputbuf_read_en;
    wire conv33_en;
    wire output_en;

    // 状态信号
    wire weight_load_done;
    wire bias_load_done;
    wire scale_load_done;
    wire input_ready;
    wire calc_valid;
    wire output_done;

    // 权重缓存
    wire [DATA_WIDTH-1:0] w0, w1, w2, w3, w4, w5, w6, w7, w8;
    wire                  weight_valid;
    // 偏置缓存
    wire [BIAS_WIDTH-1:0] bias;
    wire                  bias_valid;
    // 缩放系数缓存
    wire [BIAS_WIDTH-1:0] scale;
    wire                  scale_valid;

    // 输入数据缓存
    wire [DATA_WIDTH-1:0] d00, d01, d02, d10, d11, d12, d20, d21, d22;

    // 控制模块
    conv33_ctrl u_ctrl(
        .clk                (clk),
        .rst                (rst),
        .weight_load_done   (weight_load_done),
        .bias_load_done     (bias_load_done),
        .scale_load_done    (scale_load_done),
        .input_ready        (input_ready),
        .calc_valid         (calc_valid),
        .output_done        (output_done),
        .load_weight_en     (load_weight_en),
        .read_weight_en     (read_weight_en),
        .load_bias_en       (load_bias_en),
        .read_bias_en       (read_bias_en),
        .load_scale_en      (load_scale_en),
        .read_scale_en      (read_scale_en),
        .inputbuf_read_en   (inputbuf_read_en),
        .conv33_en          (conv33_en),
        .output_en          (output_en)
    );

    // 权重模块
    conv33_weight_input #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_weight_input(
        .clk                (clk),
        .rst                (rst),
        .load_en            (load_weight_en),
        .load_data          (weight_data),
        .read_en            (read_weight_en),
        .weight_0           (w0),
        .weight_1           (w1),
        .weight_2           (w2),
        .weight_3           (w3),
        .weight_4           (w4),
        .weight_5           (w5),
        .weight_6           (w6),
        .weight_7           (w7),
        .weight_8           (w8),
        .weight_load        (weight_load_done),
        .valid              (weight_valid)
    );

    // 偏置模块
    conv33_bias_input #(
        .BIAS_WIDTH(BIAS_WIDTH)
    ) u_bias_input(
        .clk      (clk),
        .rst      (rst),
        .load_en  (load_bias_en),
        .load_data(bias_data),
        .read_en  (read_bias_en),
        .bias     (bias),
        .valid    (bias_valid),
        .bias_load(bias_load_done)
    );

    // 缩放系数模块
    conv33_scale_input #(
        .SCALE_WIDTH(BIAS_WIDTH)
    ) u_scale_input(
        .clk      (clk),
        .rst      (rst),
        .load_en  (load_scale_en),
        .load_data(scale_data),
        .read_en  (read_scale_en),
        .scale    (scale),
        .valid    (scale_valid),
        .scale_load(scale_load_done)
    );

    // 输入模块
    conv33_input #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_input(
        .clk     (clk),
        .rst     (rst),
        .input_valid(input_valid),
        .in_0_0  (in_0_0),
        .in_0_1  (in_0_1),
        .in_0_2  (in_0_2),
        .in_1_0  (in_1_0),
        .in_1_1  (in_1_1),
        .in_1_2  (in_1_2),
        .in_2_0  (in_2_0),
        .in_2_1  (in_2_1),
        .in_2_2  (in_2_2),
        .out_0_0 (d00),
        .out_0_1 (d01),
        .out_0_2 (d02),
        .out_1_0 (d10),
        .out_1_1 (d11),
        .out_1_2 (d12),
        .out_2_0 (d20),
        .out_2_1 (d21),
        .out_2_2 (d22),
        .input_ready(input_ready),
        .inputbuf_read_en(inputbuf_read_en)
    );

    //计算模块
    wire [OUT_WIDTH-1:0] result;

    conv33_calc #(
        .DATA_WIDTH(DATA_WIDTH),
        .MUL_WIDTH (MUL_WIDTH),
        .OUT_WIDTH (OUT_WIDTH)
    ) u_calc(
        .clk     (clk),
        .rst     (rst),
        .conv33_en(conv33_en),
        .data_0_0(d00),
        .data_0_1(d01),
        .data_0_2(d02),
        .data_1_0(d10),
        .data_1_1(d11),
        .data_1_2(d12),
        .data_2_0(d20),
        .data_2_1(d21),
        .data_2_2(d22),
        .weight_0(w0),
        .weight_1(w1),
        .weight_2(w2),
        .weight_3(w3),
        .weight_4(w4),
        .weight_5(w5),
        .weight_6(w6),
        .weight_7(w7),
        .weight_8(w8),
        .bias    (bias),
        .result  (result),
        .valid   (calc_valid)
    );

    //输出模块
    conv33_output #(
        .OUT_WIDTH(OUT_WIDTH)
    ) u_output(
        .clk     (clk),
        .rst     (rst),
        .in_valid(calc_valid),
        .in_data (result),
        .out_valid(out_valid),
        .out_data (out_data)
    );

    assign output_done = out_valid;

endmodule
