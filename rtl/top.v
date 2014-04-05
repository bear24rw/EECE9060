module top(
    input CLOCK_50,

    input [9:0] SW,
    input [3:0] KEY,

    output [9:0] LEDR,
    output [7:0] LEDG,

    output [6:0] HEX0,
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,

    input  UART_RXD,
    output UART_TXD
);

    wire cpu_clk = CLOCK_50;
    wire rst = KEY[0];

    wire [15:0] addr;
    wire       cpu_we;
    wire [7:0] cpu_di;
    wire [7:0] cpu_do;
    wire [7:0] ram_di;
    wire [7:0] ram_do;
    wire [7:0] io_di;
    wire [7:0] io_do;
    wire [7:0] uart_rx_data;
    wire [7:0] uart_tx_data;
    wire uart_rx_done;
    wire uart_tx_done;
    wire uart_transmit;
    wire [6:0] seg0;
    wire [6:0] seg1;
    wire [6:0] seg2;
    wire [6:0] seg3;

    cpu cpu(
        .clk(cpu_clk),
        .rst(rst),
        .addr(addr),
        .di(cpu_di),
        .do(cpu_do),
        .we(cpu_we)
    );

    mmu mmu(
        .addr(addr),
        .cpu_di(cpu_di),
        .cpu_do(cpu_do),
        .ram_di(ram_di),
        .ram_do(ram_do),
        .io_di(io_di),
        .io_do(io_do)
    );

    ram ram(
        .clk(cpu_clk),
        .addr(addr[12:0]),
        .we(cpu_we),
        .do(ram_do),
        .di(ram_di)
    );

    io io(
        .clk(cpu_clk),
        .rst(rst),

        .addr(addr),
        .we(cpu_we),
        .do(io_do),
        .di(io_di),

        .switches(SW),
        .keys(KEY),
        .ledr(LEDR),
        .ledg(LEDG),
        .seg0(seg0),
        .seg1(seg1),
        .seg2(seg2),
        .seg3(seg3),
        .uart_rxd_data(uart_rx_data),
        .uart_txd_data(uart_tx_data),
        .uart_rxd_done(uart_rx_done),
        .uart_txd_done(uart_tx_done),
        .uart_transmit(uart_transmit)
    );

    uart uart(
        .sys_clk(CLOCK_50),
        .sys_rst(rst),
        .uart_rx(UART_RXD),
        .uart_tx(UART_TXD),
        .divisor(50000000/115200/16),
        .rx_data(uart_rx_data),
        .tx_data(uart_tx_data),
        .rx_done(uart_rx_done),
        .tx_done(uart_tx_done),
        .tx_wr(uart_transmit)
    );

    seven_seg s0(seg0, HEX0);
    seven_seg s1(seg1, HEX1);
    seven_seg s2(seg2, HEX2);
    seven_seg s3(seg3, HEX3);

endmodule
