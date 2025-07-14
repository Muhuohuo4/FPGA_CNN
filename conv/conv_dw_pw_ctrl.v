module conv_dw_pw_ctrl #(
    parameter DW_IN_CH  = 16,
    parameter PW_OUT_CH = 32
) (
    input  wire clk,
    input  wire rst,
    input  wire start,

    input  wire sw_valid,
    input  wire conv_valid,
    input  wire relu_valid,

    output reg  sw_start,
    output reg  conv_start,
    output reg  relu_start,
    output reg  write_en,

    output reg  [$clog2(DW_IN_CH)-1:0]  input_ch_idx,
    output reg  [$clog2(PW_OUT_CH)-1:0] output_ch_idx,

    output reg  done
);

    typedef enum reg [3:0] {
        IDLE,
        LOAD_INPUT,
        WAIT_SW,
        WAIT_CONV,
        ACCUM,
        NEXT_INPUT,
        ACTIVATE,
        WRITE,
        NEXT_OUTPUT,
        FINISH
    } state_t;

    state_t state, next;

    reg [$clog2(DW_IN_CH)-1:0]  input_ch_cnt;
    reg [$clog2(PW_OUT_CH)-1:0] output_ch_cnt;

    // 状态转移
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= next;
    end

    // FSM 控制逻辑
    always @(*) begin
        sw_start   = 0;
        conv_start = 0;
        relu_start = 0;
        write_en   = 0;
        done       = 0;

        next = state;
        case (state)
            IDLE:
                if (start) next = LOAD_INPUT;
            LOAD_INPUT: begin
                sw_start = 1;
                next = WAIT_SW;
            end
            WAIT_SW:
                if (sw_valid) next = WAIT_CONV;
            WAIT_CONV: begin
                conv_start = 1;
                if (conv_valid) next = ACCUM;
            end
            ACCUM:
                next = (input_ch_cnt == DW_IN_CH-1) ? ACTIVATE : NEXT_INPUT;
            NEXT_INPUT:
                next = LOAD_INPUT;
            ACTIVATE: begin
                relu_start = 1;
                if (relu_valid) next = WRITE;
            end
            WRITE: begin
                write_en = 1;
                next = (output_ch_cnt == PW_OUT_CH-1) ? FINISH : NEXT_OUTPUT;
            end
            NEXT_OUTPUT:
                next = LOAD_INPUT;
            FINISH: begin
                done = 1;
                next = IDLE;
            end
        endcase
    end

    // 计数器控制
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            input_ch_cnt  <= 0;
            output_ch_cnt <= 0;
        end else begin
            case (state)
                LOAD_INPUT:
                    input_ch_idx <= input_ch_cnt;
                ACCUM: begin
                    if (input_ch_cnt < DW_IN_CH-1)
                        input_ch_cnt <= input_ch_cnt + 1;
                    else
                        input_ch_cnt <= 0;
                end
                WRITE:
                    output_ch_cnt <= output_ch_cnt + 1;
            endcase
            output_ch_idx <= output_ch_cnt;
        end
    end

endmodule
