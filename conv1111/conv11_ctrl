module conv11_ctrl (
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

    typedef enum reg [2:0] {
        IDLE, LOAD_W, LOAD_I, CALC, WAIT, OUT
    } state_t;

    state_t state, next;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next;
    end

    always @(*) begin
        // 默认值
        input_start   = 0;
        weight_start  = 0;
        calc_start    = 0;
        output_start  = 0;
        done          = 0;
        next          = state;

        case (state)
            IDLE: if (start) next = LOAD_W;
            LOAD_W: begin
                weight_start = 1;
                if (weight_done) next = LOAD_I;
            end
            LOAD_I: begin
                input_start = 1;
                if (input_done) next = CALC;
            end
            CALC: begin
                calc_start = 1;
                if (calc_done) next = WAIT;
            end
            WAIT: next = OUT;
            OUT: begin
                output_start = 1;
                if (output_done) begin
                    done = 1;
                    next = IDLE;
                end
            end
        endcase
    end

endmodule
