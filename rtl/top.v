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

`ifdef SIMULATION
    wire cpu_clk = CLOCK_50;
`else
    wire cpu_clk;
    clk_div #(.COUNT(10000)) clk_div(CLOCK_50, cpu_clk);
`endif

    reg rst = 0;
    reg boot_en = 0;

    always @(posedge cpu_clk) begin
        rst <= SW[9];
        boot_en <= SW[8];
    end

    wire [15:0] cpu_addr;
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
    wire [7:0] boot_data;
    wire [15:0] boot_addr;
    wire [7:0] boot_tx_data;
    wire       boot_transmit;

    cpu cpu(
        .clk(cpu_clk),
        .rst(rst),
        .addr(cpu_addr),
        .di(cpu_di),
        .do(cpu_do),
        .we(cpu_we)
    );

    mmu mmu(
        .addr(cpu_addr),
        .cpu_di(cpu_di),
        .cpu_do(cpu_do),
        .ram_di(ram_di),
        .ram_do(ram_do),
        .io_di(io_di),
        .io_do(io_do),
        .boot_en(boot_en),
        .boot_data(boot_data)
    );

    wire ram_we = boot_en ? 1 : cpu_we;
    wire [15:0] ram_addr = boot_en ? boot_addr : cpu_addr;
    //wire [15:0] ram_addr = boot_en ? boot_addr : SW;
    wire ram_clk = boot_en ? CLOCK_50 : cpu_clk;
    wire [15:0] ram_cur_addr;

    ram ram(
        .clk(ram_clk),
        .addr(ram_addr[12:0]),
        .we(ram_we),
        .do(ram_do),
        .di(ram_di),
        .cur_addr(ram_cur_addr)
    );

    io io(
        .clk(cpu_clk),
        .rst(rst),

        .addr(cpu_addr),
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
        .uart_transmit(uart_transmit),
        .boot_tx_data(boot_tx_data),
        .boot_transmit(boot_transmit),
        .boot_en(boot_en)
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

    //seven_seg s0(seg0, HEX0);
    //seven_seg s1(seg1, HEX1);
    //seven_seg s2(seg2, HEX2);
    //seven_seg s3(seg3, HEX3);
    seven_seg s0(ram_cur_addr[3:0], HEX0);
    seven_seg s1(ram_cur_addr[7:4], HEX1);
    seven_seg s2(ram_cur_addr[11:8], HEX2);
    seven_seg s3(ram_cur_addr[15:12], HEX3);

    bootloader bootloader(
        .clk(CLOCK_50),
        .rst(rst),
        .rx_data(uart_rx_data),
        .tx_data(boot_tx_data),
        .rx_done(uart_rx_done),
        .tx_done(uart_tx_done),
        .transmit(boot_transmit),
        .ram_addr(boot_addr),
        .ram_data(boot_data)
    );

endmodule
