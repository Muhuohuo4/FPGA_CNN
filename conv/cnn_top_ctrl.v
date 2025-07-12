module cnn_top_ctrl (
    input  wire clk,
    input  wire rst,
    input  wire start,
    output reg  conv0_start,
    input  wire conv0_done,
    output reg  done
);

    typedef enum reg [1:0] {
        IDLE,
        CONV0_START,
        CONV0_WAIT,
        FINISH
    } state_t;

    state_t state, next;

    // 状态转移
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next;
    end

    // 控制逻辑
    always @(*) begin
        conv0_start = 0;
        done        = 0;
        case (state)
            IDLE: begin
                if (start)
                    next = CONV0_START;
                else
                    next = IDLE;
            end
            CONV0_START: begin
                conv0_start = 1;
                next = CONV0_WAIT;
            end
            CONV0_WAIT: begin
                if (conv0_done)
                    next = FINISH;
                else
                    next = CONV0_WAIT;
            end
            FINISH: begin
                done = 1;
                next = IDLE;
            end
        endcase
    end

endmodule
