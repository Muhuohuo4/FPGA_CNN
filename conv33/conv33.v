module conv33 #(
    parameter                     DATA_WIDTH = 8,
    parameter                     MUL_WIDTH  = 16,
    parameter                     OUT_WIDTH  = 8
)(
    input  wire                   clk,
    input  wire                   rst,
    
    input  wire                   data_valid_in,
    input  wire                   data_ready_out,
    output wire                   weight_ready_out,
    output wire                   weight_valid_in,    
    output reg                    out_valid_out,
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
    wire load_weight_en;
    wire read_weight_en;
    wire inputbuf_read_en;
    wire conv33_en;
    wire output_en;

    // 状态信号
    wire weight_load_done;
    wire input_ready;
    wire calc_valid;
    wire output_done;

    // 权重缓存
    wire [DATA_WIDTH-1:0] w0, w1, w2, w3, w4, w5, w6, w7, w8;
    wire                  weight_valid;

    // 输入数据缓存
    wire [DATA_WIDTH-1:0] d00, d01, d02, d10, d11, d12, d20, d21, d22;

    // 控制模块
    conv33_ctrl u_ctrl(
        .clk                (clk),
        .rst                (rst),
        .weight_load_done   (weight_load_done),
        .input_ready        (input_ready),
        .calc_valid         (calc_valid),
        .output_done        (output_done),
        .load_weight_en     (load_weight_en),
        .read_weight_en     (read_weight_en),
        .inputbuf_read_en   (inputbuf_read_en),
        .conv33_en          (conv33_en),
        .output_en          (output_en)
    );

    // 权重模块
    conv33_weight_input u_weight_input(
        .clk                (clk),
        .rst                (rst),
        .load_en            (load_weight_en),
        .load_data          (weight_data),
        .read_en            (read_weight_en),
        .weight_0           (weight_0),
        .weight_1           (weight_1),
        .weight_2           (weight_2),
        .weight_3           (weight_3),
        .weight_4           (weight_4),
        .weight_5           (weight_5),
        .weight_6           (weight_6),
        .weight_7           (weight_7),
        .weight_8           (weight_8),
        .weight_load        (weight_load_done),
        .valid              (weight_valid_in)
    );

    // 输入模块
    conv33_input u_input(
        .clk            (clk),
        .rst            (rst),
        .input_valid    (data_valid_in),
        .in_0_0         (data_in_0_0),
        .in_0_1         (data_in_0_1),
        .in_0_2         (data_in_0_2),
        .in_1_0         (data_in_1_0),
        .in_1_1         (data_in_1_1),
        .in_1_2         (data_in_1_2),
        .in_2_0         (data_in_2_0),
        .in_2_1         (data_in_2_1),
        .in_2_2         (data_in_2_2),
        .out_0_0        (data_0_0),
        .out_0_1        (data_0_1),
        .out_0_2        (data_0_2),
        .out_1_0        (data_1_0),
        .out_1_1        (data_1_1),
        .out_1_2        (data_1_2),
        .out_2_0        (data_2_0),
        .out_2_1        (data_2_1),
        .out_2_2        (data_2_2),
        .DATA_WIDTH     (DATA_WIDTH),
        .MUL_WIDTH      (MUL_WIDTH),
        .OUT_WIDTH      (OUT_WIDTH)
    ) 
    conv33_calc u_calc(
        .clk     (clk),
        .rst     (rst),
        .conv33_en(conv33_en),
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
        .result             (result),
        .valid              (calc_valid)
    );

    //输出模块
    conv33_output #(
        .OUT_WIDTH(OUT_WIDTH)
    ) u_output(
        .clk     (clk),
        .rst     (rst),
        .in_valid(calc_valid),
        .in_data (result),
        .out_valid(out_valid_out),
        .out_data (out_data)
    );

    assign output_done = out_valid_out;

endmodule
