module conv33_input_ctrl (
    input   wire    clk,
    input   wire    rst,
    input   wire    start,          // 发起 buffer 加载
    output  reg     done,           // 发送完成

    input   wire    valid_in,       // 输入数据有效
    output  wire    ready_out,      // 准备接收
    output  reg     valid_out,      // 输出数据有效
    input   wire    ready_in        // 下游准备好接收
);
    parameter IDLE  = 1'd0;
    parameter SEND  = 1'd1;

    reg state, next;
    assign ready_out = (state == IDLE);

    // 状态寄存器
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            valid_out   <= 0;
            done        <= 0;
        end else begin
            state       <= next;
            valid_out   <= 0;
            done        <= 0;
            case (state)
                SEND: begin
                    valid_out <= 1;
                    if (ready_in)
                        done <= 1; // 发完拉高
                end
            endcase
        end
    end

    // 状态跳转与控制信号
    always @(*) begin
        next = state;
        case (state)
            IDLE: begin
                if (valid_in)
                    next = SEND;
            end

            SEND: begin
                if (ready_in)
                    next  = IDLE;
            end
        endcase
    end

endmodule
