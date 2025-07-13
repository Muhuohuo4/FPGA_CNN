module conv33_ctrl (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  done,

    output reg  input_start,
    input  wire input_done,
    output reg  weight_start,
    input  wire weight_done,
    output reg  calc_start,
    input  wire calc_done,
    output reg  output_start,
    input  wire output_done
);

    // 状态机定义
    localparam IDLE    = 3'd0;
    localparam LOAD_W  = 3'd1;
    localparam LOAD_I  = 3'd2;
    localparam COMPUTE = 3'd3;
    localparam OUTPUT  = 3'd4;

    reg [2:0] state, nxt;

    // 状态跳转
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= nxt;
    end

    // 下一状态逻辑
    always @(*) begin
        case (state)
            IDLE:    nxt = start        ? LOAD_W  : IDLE;
            LOAD_W:  nxt = weight_done  ? LOAD_I  : LOAD_W;
            LOAD_I:  nxt = input_done   ? COMPUTE : LOAD_I;
            COMPUTE: nxt = calc_done    ? OUTPUT  : COMPUTE;
            OUTPUT:  nxt = output_done  ? IDLE    : OUTPUT;
            default: nxt = IDLE;
        endcase
    end

    // 输出控制信号
    always @(*) begin
        // 默认拉低
        input_start  = 0;
        weight_start = 0;
        calc_start   = 0;
        output_start = 0;
        done         = 0;

        case (state)
            LOAD_W:     weight_start = 1;
            LOAD_I:     input_start  = 1;
            COMPUTE:    calc_start   = 1;
            OUTPUT: begin
                        output_start = 1;
                        done         = output_done;
            end
        endcase
    end

endmodule
