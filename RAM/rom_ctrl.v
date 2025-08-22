// ROM 控制器：统一控制 channel_1_rom ~ channel_6 的读写操作，并输出 pixel_r/g/b 和写入接口
module rom_ctrl (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [13:0] addr_read_ch1,
    input  wire [13:0] addr_read_ch2,
    input  wire [13:0] addr_read_ch3,
    input  wire [13:0] addr_read_ch4,
    input  wire [13:0] addr_read_ch5,
    input  wire [13:0] addr_read_ch6,
    input  wire [13:0] addr_write_ch1,
    input  wire [13:0] addr_write_ch2,
    input  wire [13:0] addr_write_ch3,
    input  wire [13:0] addr_write_ch4,
    input  wire [13:0] addr_write_ch5,
    input  wire [13:0] addr_write_ch6,
    input  wire        we1,
    input  wire        we2,
    input  wire        we3,
    input  wire        we4,
    input  wire        we5,
    input  wire        we6,
    input  wire [7:0]  data_in_ch1,
    input  wire [7:0]  data_in_ch2,
    input  wire [7:0]  data_in_ch3,
    input  wire [7:0]  data_in_ch4,
    input  wire [7:0]  data_in_ch5,
    input  wire [7:0]  data_in_ch6,
    output wire [7:0]  data_out_ch1,
    output wire [7:0]  data_out_ch2,
    output wire [7:0]  data_out_ch3,
    output wire [7:0]  data_out_ch4,
    output wire [7:0]  data_out_ch5,
    output wire [7:0]  data_out_ch6
);

    channel_1 u_ch1 (
        .clk(clk),
        .we(we1),
        .addr_write(addr_write_ch1),
        .addr_read(addr_read_ch1),
        .data_in(data_in_ch1),
        .data_out(data_out_ch1)
    );

    channel_2 u_ch2 (
        .clk(clk),
        .we(we2),
        .addr_write(addr_write_ch2),
        .addr_read(addr_read_ch2),
        .data_in(data_in_ch2),
        .data_out(data_out_ch2)
    );

    channel_3 u_ch3 (
        .clk(clk),
        .we(we3),
        .addr_write(addr_write_ch3),
        .addr_read(addr_read_ch3),
        .data_in(data_in_ch3),
        .data_out(data_out_ch3)
    );

    channel_4 u_ch4 (
        .clk(clk),
        .we(we4),
        .addr_write(addr_write_ch4),
        .addr_read(addr_read_ch4),
        .data_in(data_in_ch4),
        .data_out(data_out_ch4)
    );

    channel_5 u_ch5 (
        .clk(clk),
        .we(we5),
        .addr_write(addr_write_ch5),
        .addr_read(addr_read_ch5),
        .data_in(data_in_ch5),
        .data_out(data_out_ch5)
    );

    channel_6 u_ch6 (
        .clk(clk),
        .we(we6),
        .addr_write(addr_write_ch6),
        .addr_read(addr_read_ch6),
        .data_in(data_in_ch6),
        .data_out(data_out_ch6)
    );

endmodule
