module conv_dw_pw #(
    parameter LAYER_DW_NUM  = 1,
    parameter LAYER_PW_NUM  = 2,
    parameter DW_IN_CH      = 16,
    parameter DW_IN_HW      = 64,
    parameter DW_OUT_CH     = 16,
    parameter DW_OUT_HW     = 64,
    parameter DW_STRIDE     = 1,
    parameter PW_IN_CH      = 16,
    parameter PW_IN_HW      = 64,
    parameter PW_OUT_CH     = 32,
    parameter PW_OUT_HW     = 64,
    parameter BIAS_WIDTH    = 32,
    parameter SCALE_WIDTH   = 16
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    output wire        done,
    output wire [7:0]  dout,
    output wire        dout_valid
);

    // === 控制信号 ===
    wire sw_start, conv_start, relu_start, write_en;
    wire sw_valid, conv_valid, relu_valid;

    wire [1:0]  input_ch_idx;
    wire [3:0]  output_ch_idx;

    wire        bias_scale_start_33;
    wire [4:0]  bias_scale_layer_33;
    wire [9:0]  bias_scale_ch_33;
    wire        bias_scale_start_11;
    wire [4:0]  bias_scale_layer_11;
    wire [9:0]  bias_scale_ch_11;

    wire signed [7:0]  sw_data_00, sw_data_01, sw_data_02;
    wire signed [7:0]  sw_data_10, sw_data_11, sw_data_12;
    wire signed [7:0]  sw_data_20, sw_data_21, sw_data_22;

    wire signed [15:0] conv_result;
    reg  signed [15:0] acc_result;

    wire signed [BIAS_WIDTH-1:0]    bias_33;
    wire signed [BIAS_WIDTH-1:0]    bias_11;
    wire signed [SCALE_WIDTH-1:0]   scale_33;
    wire signed [SCALE_WIDTH-1:0]   scale_11;

    wire [7:0] relu_out;

    // === 控制模块 ===
    layer_1_ctrl ctrl   (
        .clk            (clk),          .rst            (rst),          .start            (start),
        .sw_valid       (sw_valid),     .conv_valid     (conv_valid),   .relu_valid       (relu_valid),
        .sw_start       (sw_start),     .conv_start     (conv_start),   .relu_start       (relu_start),
        .write_en       (write_en),
        .input_ch_idx   (input_ch_idx),
        .output_ch_idx  (output_ch_idx),
        .done           (done)
    );
    
    feature_map_buffer #(
        .WRITE_H            (OUT_HW),
        .WRITE_W            (OUT_HW),
        .WRITE_C            (OUT_CH),
        .READ_H             (DW_IN_HW),
        .READ_W             (DW_IN_HW),
        .READ_C             (DW_IN_CH),
        .mode_sel           (0)  // b写a读
    ) u_feature_map_b       (
        .clk                (clk),
        .rst                (rst),
        .write_en           (fm_write_en_b),    // 写端口：连接a
        .write_ch           (fm_write_ch_b),
        .write_h            (fm_write_h_b),
        .write_w            (fm_write_w_b),
        .read_en            (fm_read_en_b),     // 读端口：连接b
        .read_ch            (fm_read_ch_b),
        .read_h             (fm_read_h_b),
        .read_w             (fm_read_w_b),
        .data_in            (fm_data_in_b),
        .data_out           (fm_data_out_b)
    );
    
    assign fm_data_out_b = sw_data_in_33;

    // === 滑窗 ===
    sliding_window_3x3 #(
        .IMG_WIDTH          (DW_IN_HW),         // 图像宽度
        .STRIDE             (DW_STRIDE)         // 1/2
    ) u_sw (
        .clk                (clk),
        .rst                (rst),
        .valid_in           (sw_valid_in_33),                       //sw_valid_in
        .ready_out          (sw_ready_out_33),                      //sw_ready_out
        .valid_out          (sw_valid_out_33),                      // 输出有效
        .ready_in           (sw_ready_in_33),           
        .data_in            (sw_data_in_33),                        // 输入像素
        .data_out_0         (sw_data_00), .data_out_1       (sw_data_01), .data_out_2       (sw_data_02),
        .data_out_3         (sw_data_10), .data_out_4       (sw_data_11), .data_out_5       (sw_data_12),
        .data_out_6         (sw_data_20), .data_out_7       (sw_data_21), .data_out_8       (sw_data_22)
    );
    weight_mem #(
        .LAYER_NUM          (LAYER_DW_NUM),
        .IN_CH_NUM          (DW_IN_CH),
        .OUT_CH_NUM         (DW_OUT_CH),
        .KERNEL_SIZE        (9)
    ) u_weight_mem_33       (
        .clk                (clk),
        .rst                (rst),
        .start              (weight_start_33),
        .in_ch              (in_ch_weight_33),
        .out_ch             (out_ch_weight_33),
        .weight_out         (weight_out_33),
        .valid_out          (valid_out_weight_33),
        .ready_in           (ready_in_weight_33)
    );
    wire sw_valid_out_33 = input_valid_in_33;
    wire sw_ready_in_33  = input_ready_out_33;
    wire signed [7:0] weight_out_33 = weight_data_33;
    wire valid_out_weight_33 = weight_valid_in_33;
    wire ready_in_weight_33 = weight_ready_out_33;
    conv33 u_conv33 (
        .clk                (clk),
        .rst                (rst),
        .start              (conv33_start),                 // 卷积开始信号
        .done               (conv33_done),                  // 卷积完成信号
        .input_valid_in     (input_valid_in_33),            // 来自滑窗
        .input_ready_out    (input_ready_out_33),           // 可留空或连接到滑窗控制
        .weight_valid_in    (weight_valid_in_33),           // 暂不需要
        .weight_ready_out   (weight_ready_out_33),          // 暂不需要
        .out_valid_out      (out_valid_out_33),
        .out_ready_in       (out_ready_in_33),              // 输入数据有效信号
        .weight_data        (weight_data_33),               // 权重加载接口
        .data_in_0_0        (sw_data_00), .data_in_0_1      (sw_data_01), .data_in_0_2      (sw_data_02),
        .data_in_1_0        (sw_data_10), .data_in_1_1      (sw_data_11), .data_in_1_2      (sw_data_12),
        .data_in_2_0        (sw_data_20), .data_in_2_1      (sw_data_21), .data_in_2_2      (sw_data_22),
        .out_data           (out_data_33)
    );
    wire out_valid_out_33 = valid_in_relu_33;
    wire out_ready_in_33  = ready_out_relu_33;
    wire signed [31:0] out_data_33 = data_in_relu_33;
    bias_scale_mem #(
        .LAYER_NUM          (LAYER_DW_NUM),
        .CH_NUM             (DW_OUT_CH)
    ) bias_scale_mem_33     (
        .clk                (clk),
        .rst                (rst),
        .start              (bias_scale_start_33),
        .layer_idx          (bias_scale_layer_33),
        .ch_idx             (bias_scale_ch_33),
        .bias_out           (bias_33),
        .scale_out          (scale_33)
    );
    bias_scale_relu u_relu33 (
        .clk            (clk),
        .rst            (rst),
        .valid_in       (valid_in_relu_33),
        .ready_out      (ready_out_relu_33),         
        .valid_out      (valid_out_relu_33),     
        .ready_in       (ready_in_relu_33),  
        .data_in        (data_in_relu_33),
        .bias           (bias_33),
        .scale_q8_8     (scale_33),
        .data_out       (data_out_relu_33)
    );

    wire [7:0] data_out_relu_33 = fm_data_in_b;

    assign ready_in_relu_33 = 1;  
    assign valid_out_relu_33 = 1; 

    feature_map_buffer #(
        .WRITE_H        (OUT_HW),
        .WRITE_W        (OUT_HW),
        .WRITE_C        (OUT_CH),
        .READ_H         (IN_HW),
        .READ_W         (IN_HW),
        .READ_C         (IN_CH),
        .mode_sel       (1)                 // a写b读
    ) u_feature_map_a   (
        .clk            (clk),
        .rst            (rst),
        .write_en       (fm_write_en_a),    // 写端口：连接 a
        .write_ch       (fm_write_ch_a),
        .write_h        (fm_write_h_a),
        .write_w        (fm_write_w_a),
        .read_en        (fm_read_en_a),     // 读端口：连接 b
        .read_ch        (fm_read_ch_a),
        .read_h         (fm_read_h_a),
        .read_w         (fm_read_w_a),
        .data_in        (fm_data_in_a),
        .data_out       (fm_data_out_a)
    );

    weight_mem #(
        .LAYER_NUM          (LAYER_PW_NUM),
        .IN_CH_NUM          (PW_IN_CH),
        .OUT_CH_NUM         (PW_OUT_CH),
        .KERNEL_SIZE        (1)
    ) u_weight_mem_11       (
        .clk                (clk),
        .rst                (rst),
        .start              (weight_start_11),
        .in_ch              (in_ch_weight_11),
        .out_ch             (out_ch_weight_11),
        .weight_out         (weight_out_11),
        .valid_out          (valid_out_weight_11),
        .ready_in           (ready_in_weight_11)
    );
    assign fm_data_out_a = data_in_33;
    wire signed [7:0] weight_out_11 = weight_data_11;
    wire valid_out_weight_11 = weight_valid_in_11;
    wire ready_in_weight_11 = weight_ready_out_11;
    conv11 u_conv11 (
        .clk                (clk),
        .rst                (rst),
        .start              (conv11_start),                 // 卷积开始信号
        .done               (conv11_done),                  // 卷积完成信号
        .input_valid_in     (input_valid_in_11),            // 来自滑窗
        .input_ready_out    (input_ready_out_11),           // 可留空或连接到滑窗控制
        .weight_valid_in    (weight_valid_in_11),           // 暂不需要
        .weight_ready_out   (weight_ready_out_11),          // 暂不需要
        .out_valid_out      (out_valid_out_11),
        .out_ready_in       (out_ready_in_11),              // 输入数据有效信号
        .weight_data        (weight_data_11),               // 权重加载接口
        .data_in            (data_in_33)
        .out_data           (out_data_33)
    );
    adder_tree_top #(
        .CHANNELS           (PW_OUT_CH)
    ) u_adder_tree_top (
        .clk                (clk),
        .rst                (rst),
        .valid_in           (valid_in_adder),
        .ready_out          (ready_out_adder),                // 恒为 1，也可以接给 conv11 控制
        .valid_out          (valid_out_adder),
        .in_index           (in_index_adder),  // 通道序号 0 ~ 127
        .data_in            (data_in_adder),     // 每拍一个通道数据
        .data_out           (data_out_adder)         // 所有通道累加结果（仅 sum_valid = 1 时有效）
    );

    bias_scale_mem #(
        .LAYER_NUM      (LAYER_DW_NUM),
        .CH_NUM         (DW_OUT_CH)
    ) bias_scale_mem_11 (
        .clk            (clk),
        .rst            (rst),
        .start          (bias_scale_start_11),
        .layer_idx      (bias_scale_layer_11),
        .ch_idx         (bias_scale_ch_11),
        .bias_out       (bias_11),
        .scale_out      (scale_11)
    );
    bias_scale_relu u_relu11 (
        .clk            (clk),
        .rst            (rst),
        .valid_in       (valid_in_relu_11),
        .ready_out      (ready_out_relu_11),         
        .valid_out      (valid_out_relu_11),     
        .ready_in       (ready_in_relu_11),  
        .data_in        (data_in_relu_11),
        .bias           (bias_11),
        .scale_q8_8     (scale_11),
        .data_out       (data_out_relu_11)
    );

endmodule
