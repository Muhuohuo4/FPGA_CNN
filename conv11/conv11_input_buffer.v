module conv11_input_buffer #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst,

    input wire input_valid,
    input wire [DATA_WIDTH-1:0] in_0_0,

    input wire inputbuf_read_en,

    output reg [DATA_WIDTH-1:0] out_0_0,
    output reg inputbuf_load
);

    reg [DATA_WIDTH-1:0] buf_0_0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            inputbuf_load <= 0;
        end else if (input_valid) begin
            buf_0_0 <= in_0_0;
            inputbuf_load <= 1;
        end else if (inputbuf_read_en) begin
            inputbuf_load <= 0;
        end
    end

    always @(posedge clk) begin
        if (inputbuf_read_en)
            out_0_0 <= buf_0_0;
    end

endmodule
