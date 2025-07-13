module conv33 #(
    parameter                       DATA_WIDTH = 8,
    parameter                       MUL_WIDTH  = 16,
    parameter                       OUT_WIDTH  = 32
)(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     start,
    output wire                     done,

    input  wire                     input_valid_in,
    output wire                     input_ready_out,
    input  wire                     weight_valid_in,
    output wire                     weight_ready_out,
    output wire                     out_valid_out,
    input  wire                     out_ready_in,

    // 权重偏置输入
    input  wire [DATA_WIDTH-1:0]    weight_data,
    input  wire [DATA_WIDTH-1:0]    data_in_0_0,
    input  wire [DATA_WIDTH-1:0]    data_in_0_1,
    input  wire [DATA_WIDTH-1:0]    data_in_0_2,
    input  wire [DATA_WIDTH-1:0]    data_in_1_0,
    input  wire [DATA_WIDTH-1:0]    data_in_1_1,
    input  wire [DATA_WIDTH-1:0]    data_in_1_2,
    input  wire [DATA_WIDTH-1:0]    data_in_2_0,
    input  wire [DATA_WIDTH-1:0]    data_in_2_1,
    input  wire [DATA_WIDTH-1:0]    data_in_2_2,
    output wire [OUT_WIDTH-1:0]     out_data
);
    
    wire input_start;
    wire input_done;
    wire weight_start;
    wire weight_done;
    wire calc_start;
    wire calc_done;
    wire output_start;
    wire output_done; 
    wire out_valid_in;
    wire out_ready_out;

    // 权重缓存
    wire [DATA_WIDTH-1:0] weight_0, weight_1, weight_2,
                          weight_3, weight_4, weight_5,
                          weight_6, weight_7, weight_8;

    // 输入数据缓存
    wire [DATA_WIDTH-1:0] data_0_0, data_0_1, data_0_2,
                          data_1_0, data_1_1, data_1_2,
                          data_2_0, data_2_1, data_2_2;

    wire signed [OUT_WIDTH-1:0] result;

    // 控制模块
    conv33_ctrl u_ctrl(
        .clk                (clk),
        .rst                (rst),
        .start              (start),
        .done               (done),
        .input_start        (input_start),
        .input_done         (input_done),
        .weight_start       (weight_start),
        .weight_done        (weight_done),
        .calc_start         (calc_start),
        .calc_done          (calc_done),
        .output_start       (output_start),
        .output_done        (output_done)
    );

    // 权重模块
    conv33_weight_buffer u_weight(
        .clk                (clk),
        .rst                (rst),
        .start              (weight_start),
        .done               (weight_done),
        .valid_in           (weight_valid_in),
        .ready_out          (weight_ready_out),
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
        .out_2_2            (data_2_2)
    );

    conv33_calc u_calc(
        .clk                (clk),
        .rst                (rst),
        .start              (calc_start),
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
        .start              (output_start),
        .done               (output_done), 
        .valid_in           (out_valid_in),
        .ready_out          (out_ready_out),
        .valid_out          (out_valid_out),
        .ready_in           (out_ready_in),
        .data_in            (result),
        .data_out           (out_data)
    );

endmodule
