module top_conv11_1x1 (
  input  wire         clk, rst,
  // 上游像素输入（仿真可以自己驱动）
  input  wire         in_valid,
  output wire         in_ready,
  input  wire [7:0]   in_data,
  // 导出触发（仿真时拉一拍把结果写文件）
  input  wire         dump
);
  // ========= 权重 =========
  wire        w_v;           // weight_mem -> conv11
  wire        w_r;           // conv11 -> weight_mem
  wire [7:0]  w_d;

  weight_mem u_wmem (        // 你的 weight_mem.v
    .clk(clk),
    .rst(rst),
    .valid_out(w_v),
    .ready_in(w_r),
    .data_out(w_d)
    // 若有地址/选择端口，1×1先固定或置零
  );

  // ========= 卷积 1×1 =========
  wire        y_v_mid;
  wire        y_r_mid;
  wire [7:0]  y_d_mid;

  conv11 u_conv11 (          // 你的 conv11.v（里面含 ctrl/calc）
    .clk(clk),
    .rst(rst),

    // 触发：若沿用原FSM，需要给一次 start 脉冲开始一帧
    .start(in_valid),        // 简化：有输入就启动（或用我给的 conv11_ctrl_min）

    .done(),                 // 仿真可不接

    // 数据输入握手（你原文件名是 input_valid_in/input_ready_out）
    .input_valid_in(in_valid),
    .input_ready_out(in_ready),
    .data_in(in_data),

    // 权重输入握手
    .weight_valid_in(w_v),
    .weight_ready_out(w_r),
    .weight_data(w_d),

    // 输出握手
    .out_valid_out(y_v_mid),
    .out_ready_in(y_r_mid),
    .out_data(y_d_mid)
  );

  // ========= 偏置/缩放（可选）=========
  wire        y_v;
  wire        y_r;
  wire [7:0]  y_d;

  bias_scale_mem u_bsmem (    // 你的 bias_scale_mem.v：把 BN/scale 做完吐出
    .clk(clk),
    .rst(rst),
    .in_valid(y_v_mid),
    .in_ready(y_r_mid),
    .in_data (y_d_mid),
    .out_valid(y_v),
    .out_ready(y_r),
    .out_data (y_d)
  );

  // ========= 结果存储/导出 =========
  feature_map_buffer u_fmbuf ( // 你的 feature_map_buffer.v
    .clk(clk),
    .rst(rst),
    .in_valid(y_v),
    .in_ready(y_r),
    .in_data (y_d),
    // 如果模块自带写文件/读端口，按你的文件实现来接；
    // 没有的话，用我之前给的 stream_sink_mem 也可以
    .dump(dump)                // 若有这个端口；没有则忽略
  );

endmodule
