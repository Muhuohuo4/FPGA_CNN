module conv33_input_ctrl (
    input wire clk,
    input wire rst,
    input wire input_valid,
    input wire inputbuf_load,

    output reg input_ready
);

    parameter IDLE = 2'd0, WAIT = 2'd1, COMPUTE = 2'd2;
    reg [1:0] state, next;

    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= IDLE;
        else
            state <= next;
    end

    always @(*) begin
        next = state;
        input_ready = 0;
        case (state)
            IDLE: if (input_valid) next = WAIT;
            WAIT: if (inputbuf_load) begin

                next = COMPUTE;
            end
            COMPUTE: begin
                input_ready = 1;
                next = IDLE;
            end
        endcase
    end

endmodule
