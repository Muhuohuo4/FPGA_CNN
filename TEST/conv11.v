module conv11 #(
    parameter DATA_WIDTH = 8,
    parameter MUL_WIDTH  = 16,
    parameter OUT_WIDTH  = 8
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

    input  wire [DATA_WIDTH-1:0]    weight_data,
    input  wire [DATA_WIDTH-1:0]    data_in,
    output wire [OUT_WIDTH-1:0]     out_data
);

    // 中间控制信号
    wire input_start, input_done;
    wire weight_start, weight_done;
    wire calc_start, calc_done;
    wire output_start, output_done;
    wire out_valid_internal, out_ready_internal;
    wire [MUL_WIDTH-1:0] result;

    // 控制模块
    conv11_ctrl u_ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .input_start(input_start),
        .input_done(input_done),
        .weight_start(weight_start),
        .weight_done(weight_done),
        .calc_start(calc_start),
        .calc_done(calc_done),
        .output_start(output_start),
        .output_done(output_done)
    );

    // 数据处理模块
    conv11_calc u_data (
        .clk(clk),
        .rst(rst),

        .input_start(input_start),
        .input_done(input_done),
        .weight_start(weight_start),
        .weight_done(weight_done),
        .calc_start(calc_start),
        .calc_done(calc_done),
        .output_start(output_start),
        .output_done(output_done),

        .input_valid_in(input_valid_in),
        .input_ready_out(input_ready_out),
        .weight_valid_in(weight_valid_in),
        .weight_ready_out(weight_ready_out),
        .out_valid_out(out_valid_out),
        .out_ready_in(out_ready_in),

        .weight_data(weight_data),
        .data_in(data_in),
        .result(result)
    );

    assign out_data = result[OUT_WIDTH-1:0];

endmodule
