// conv33_ctrl.v
// 控制 3x3 卷积模块整体流程：依次加载权重�?�偏置和输入数据�?
// 然后启动计算并在结果输出后重新回到空闲状态�??

module conv33_ctrl (
    input  wire clk,
    input  wire rst,

    // 来自各子模块的状态信�?
    input  wire weight_load_done,
    input  wire bias_load_done,
    input  wire input_ready,
    input  wire calc_valid,
    input  wire output_done,

    // 控制信号输出
    output reg  load_weight_en,
    output reg  read_weight_en,

    output reg  load_bias_en,
    output reg  read_bias_en,

    output reg  inputbuf_read_en,

    output reg  conv33_en,
    output reg  output_en
);

    // 状�?�机定义
    parameter IDLE    = 3'd0;
    parameter LOAD_W  = 3'd1;
    parameter LOAD_B  = 3'd2;
    parameter LOAD_I  = 3'd3;
    parameter COMPUTE = 3'd4;
    parameter WAIT    = 3'd5;
    parameter OUTPUT  = 3'd6;

    reg [2:0] state, nxt;

    // 状�?�寄存器
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= nxt;
    end

    // 状�?�转移�?�辑
    always @(*) begin
        nxt = state;
        case (state)
            IDLE:    nxt = LOAD_W;
            LOAD_W:  nxt = weight_load_done ? LOAD_B  : LOAD_W;
            LOAD_B:  nxt = bias_load_done   ? LOAD_I  : LOAD_B;
            LOAD_I:  nxt = input_ready      ? COMPUTE : LOAD_I;
            COMPUTE: nxt = WAIT;
            WAIT:    nxt = calc_valid       ? OUTPUT  : WAIT;
            OUTPUT:  nxt = output_done      ? IDLE    : OUTPUT;
            default: nxt = IDLE;
        endcase
    end

    // 默认输出为低电平
    always @(*) begin
        load_weight_en = 0;
        read_weight_en = 0;
        load_bias_en   = 0;
        read_bias_en   = 0;
        inputbuf_read_en  = 0;
        conv33_en      = 0;
        output_en      = 0;

        case (state)
            LOAD_W: begin
                load_weight_en = 1;
                read_weight_en = weight_load_done;
            end
            LOAD_B: begin
                load_bias_en = 1;
                read_bias_en = bias_load_done;
            end
            LOAD_I: begin
                inputbuf_read_en = 1;
            end
            COMPUTE: begin
                conv33_en = 1;             // 触发计算
            end
            OUTPUT: begin
                output_en = 1;             // 启动结果输出
            end
        endcase
    end

endmodule
