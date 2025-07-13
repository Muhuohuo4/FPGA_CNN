module conv11_input_ctrl (
    input   wire    clk,
    input   wire    rst,
    input   wire    start,
    output  reg     done,           // 发送完成

    input   wire    valid_in,       // 输入数据有效
    output  wire    ready_out       // 准备接收
);
    parameter IDLE  = 1'd0;
    parameter SEND  = 1'd1;

    reg state, next;
    assign ready_out = (state == IDLE);

    // 状态寄存器
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done  <= 0;
        end else begin
            state <= next;
            done  <= (state == SEND);
        end
    end

    always @(*) begin
        next = state;
        case (state)
            IDLE: if (start) next = SEND;
            SEND:            next = IDLE;
        endcase
    end

endmodule
