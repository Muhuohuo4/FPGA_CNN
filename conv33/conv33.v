module conv33 #(
    parameter                     DATA_WIDTH = 8,
    parameter                     MUL_WIDTH  = 16,
    parameter                     OUT_WIDTH  = 8
)(
    input  wire                   clk,
    input  wire                   rst,
    
    input  wire                   data_valid_in,
    output wire                   data_ready_out,
    input  wire                   weight_valid_in,
    output wire                   weight_start,
    output wire                   out_valid_out,
    input  wire                   out_ready_in,

    // 权重偏置输入
    input  wire [DATA_WIDTH-1:0]  weight_data,

    // 输入数据

    input  wire [DATA_WIDTH-1:0]  data_in_0_0,
    input  wire [DATA_WIDTH-1:0]  data_in_0_1,
    input  wire [DATA_WIDTH-1:0]  data_in_0_2,
    input  wire [DATA_WIDTH-1:0]  data_in_1_0,
    input  wire [DATA_WIDTH-1:0]  data_in_1_1,
    input  wire [DATA_WIDTH-1:0]  data_in_1_2,
    input  wire [DATA_WIDTH-1:0]  data_in_2_0,
    input  wire [DATA_WIDTH-1:0]  data_in_2_1,
    input  wire [DATA_WIDTH-1:0]  data_in_2_2,

    output wire [OUT_WIDTH-1:0]   out_data
);

    // 控制信号
    wire read_weight_en;
    wire conv33_en;
    wire output_en;

    // 状态信号
    wire weight_load_done;
    wire input_ready;
    wire out_valid_in;

    // 权重缓存
    wire [DATA_WIDTH-1:0] weight_0, weight_1, weight_2,
                          weight_3, weight_4, weight_5,
                          weight_6, weight_7, weight_8;

    // 输入数据缓存
    wire [DATA_WIDTH-1:0] data_0_0, data_0_1, data_0_2,
                          data_1_0, data_1_1, data_1_2,
                          data_2_0, data_2_1, data_2_2;
    // 控制模块
    conv33_ctrl u_ctrl(
        .clk                (clk),
        .rst                (rst),
        .weight_load_done   (weight_load_done),
        .input_ready        (input_ready),
        .calc_valid         (out_valid_in),
        .output_done        (out_valid_out),
        .load_weight_en     (weight_start),
        .read_weight_en     (read_weight_en),
        .inputbuf_read_en   (data_ready_out),
        .conv33_en          (conv33_en),
        .output_en          (output_en)
    );

    // 权重模块
    conv33_weight_input u_weight_input(
        .clk                (clk),
        .rst                (rst),
        .start              (weight_start),
        .read_en            (weight_read_en),
        .weight_load        (weight_load_done),
        .valid_out          (weight_valid_out),
        .data_in            (weight_data),
        .weight_0           (weight_0),
        .weight_1           (weight_1),
        .weight_2           (weight_2),
        .weight_3           (weight_3),
        .weight_4           (weight_4),
        .weight_5           (weight_5),
        .weight_6           (weight_6),
        .weight_7           (weight_7),
        .weight_8           (weight_8)
    );

    // 输入模块
    conv33_input u_input(
        .clk                (clk),
        .rst                (rst),
        .start              (input_start),
        .done               (input_done),
        .valid_in           (input_valid_in),
        .ready_out          (input_ready_out),
        .valid_out          (input_valid_out),
        .ready_in           (input_ready_in),
        .in_0_0             (data_in_0_0),
        .in_0_1             (data_in_0_1),
        .in_0_2             (data_in_0_2),
        .in_1_0             (data_in_1_0),
        .in_1_1             (data_in_1_1),
        .in_1_2             (data_in_1_2),
        .in_2_0             (data_in_2_0),
        .in_2_1             (data_in_2_1),
        .in_2_2             (data_in_2_2),
        .out_0_0            (data_0_0),
        .out_0_1            (data_0_1),
        .out_0_2            (data_0_2),
        .out_1_0            (data_1_0),
        .out_1_1            (data_1_1),
        .out_1_2            (data_1_2),
        .out_2_0            (data_2_0),
        .out_2_1            (data_2_1),
        .out_2_2            (data_2_2),
    ) 
    conv33_calc u_calc(
        .clk                (clk),
        .rst                (rst),
        .start              (calc_en),
        .done               (calc_done),
        .valid_out          (out_valid_in),
        .ready_in           (out_ready_out),
        .data_0_0           (data_0_0),
        .data_0_1           (data_0_1),
        .data_0_2           (data_0_2),
        .data_1_0           (data_1_0),
        .data_1_1           (data_1_1),
        .data_1_2           (data_1_2),
        .data_2_0           (data_2_0),
        .data_2_1           (data_2_1),
        .data_2_2           (data_2_2),
        .weight_0           (weight_0),
        .weight_1           (weight_1),
        .weight_2           (weight_2),
        .weight_3           (weight_3),
        .weight_4           (weight_4),
        .weight_5           (weight_5),
        .weight_6           (weight_6),
        .weight_7           (weight_7),
        .weight_8           (weight_8),
        .result             (result)
    );

    //输出模块
    conv33_output u_output(
        .clk                (clk),
        .rst                (rst),
        .valid_in           (out_valid_in),
        .ready_out          (out_ready_out),
        .valid_out          (out_valid_out),
        .ready_in           (out_ready_in),
        .start              (output_en),
        .done               (weight_load_done), 
        .data_in            (result),
        .data_out           (out_data)
    );

endmodule
