// 图像预处理模块，调用初始化后的 channel_1~3 ROM 并写入 channel_4~6
module image_reprocess (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire signed [23:0] input_scale,
    output reg         valid,
    output reg         done
);

    reg  [13:0] addr;
    reg  [1:0]  channel;

    wire [6:0]  row = addr / 128;
    wire [6:0]  col = addr % 128;
    wire [13:0] addr_pad = (row + 1) * 130 + (col + 1);

    wire [7:0]  pixel_r, pixel_g, pixel_b;
    wire [7:0]  pixel = (channel == 2'd0) ? pixel_r :
                        (channel == 2'd1) ? pixel_g : pixel_b;

    wire signed [15:0] pixel_q8_8 = pixel << 8;
    wire signed [31:0] norm = pixel_q8_8 * input_scale;
    wire signed [15:0] result = norm[31:16] - 16'sd128;
    wire signed [7:0]  data_out = (result > 127)  ? 8'sd127 :
                                  (result < -128) ? -8'sd128 :
                                  $signed({result[15], result[6:0]});

    wire we_ch4 = (channel == 2'd0);
    wire we_ch5 = (channel == 2'd1);
    wire we_ch6 = (channel == 2'd2);

    rom_ctrl u_rom_ctrl (
        .clk(clk), .rst(rst), .start(start),
        
        .we1(1'b0), .we2(1'b0), .we3(1'b0),
        .addr_read_ch1(addr),
        .addr_read_ch2(addr),
        .addr_read_ch3(addr),
        .data_out_ch1(pixel_r),
        .data_out_ch2(pixel_g),
        .data_out_ch3(pixel_b),

        .we4(we_ch4), .we5(we_ch5), .we6(we_ch6),
        .addr_write_ch4(addr_pad),
        .addr_write_ch5(addr_pad),
        .addr_write_ch6(addr_pad),
        .data_in_ch4(data_out),
        .data_in_ch5(data_out),
        .data_in_ch6(data_out),
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            addr <= 0;
            channel <= 0;
            done <= 0;
            valid <= 0;
        end else if (start && !done) begin
            valid <= 1;
            if (addr == 14'd16383) begin
                addr <= 0;
                if (channel == 2)
                    done <= 1;
                else
                    channel <= channel + 1;
            end else begin
                addr <= addr + 1;
            end
        end else begin
            valid <= 0;
        end
    end
endmodule
