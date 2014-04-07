module soc(
    input clk,

    input  boot_trigger,
    output booting,

    output [15:0] ram_addr,
    output [7:0]  ram_di,
    input  [7:0]  ram_do,
    output        ram_we,

    input [7:0] gpi_0,
    input [7:0] gpi_1,
    input [7:0] gpi_2,
    input [7:0] gpi_3,
    input [7:0] gpi_4,
    input [7:0] gpi_5,
    input [7:0] gpi_6,
    input [7:0] gpi_7,

    output [7:0] gpo_0,
    output [7:0] gpo_1,
    output [7:0] gpo_2,
    output [7:0] gpo_3,
    output [7:0] gpo_4,
    output [7:0] gpo_5,
    output [7:0] gpo_6,
    output [7:0] gpo_7,

    input  uart_rxd,
    output uart_txd
);

    // ----------------------------------------------------
    //                      CPU
    // ----------------------------------------------------

    wire cpu_clk = ~clk;
    wire [15:0] cpu_addr;
    wire [7:0]  cpu_di;
    wire [7:0]  cpu_do;
    wire        cpu_we;
    wire        cpu_rst;

    cpu cpu(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .addr(cpu_addr),
        .di(cpu_di),
        .do(cpu_do),
        .we(cpu_we)
    );

    // ----------------------------------------------------
    //                  RAM INTERFACE
    // ----------------------------------------------------

    assign ram_addr = booting ? boot_addr : cpu_addr;
    assign ram_di   = booting ? boot_data : cpu_do;
    assign ram_we   = booting ? 1         : cpu_we;

    // ----------------------------------------------------
    //                  MEMORY MAPPER
    // ----------------------------------------------------

    mem_mapper mem_mapper(
        .addr(cpu_addr),
        .cpu_di(cpu_di),
        .ram_do(ram_do),
        .gpi_0(gpi_0),
        .gpi_1(gpi_1),
        .gpi_2(gpi_2),
        .gpi_3(gpi_3),
        .gpi_4(gpi_4),
        .gpi_5(gpi_5),
        .gpi_6(gpi_6),
        .gpi_7(gpi_7),
        .timer_do(timer_do)
    );

    // ----------------------------------------------------
    //                      TIMERS
    // ----------------------------------------------------

    wire [7:0] timer_do;

    timer timer(
        .clk(clk),
        .rst(cpu_rst),
        .addr(cpu_addr),
        .we(cpu_we),
        .do(timer_do),
        .di(cpu_do)
    );

    // ----------------------------------------------------
    //              GENERAL PURPOSE OUTPUTS
    // ----------------------------------------------------

    gpo #(.addr(`ADDR_GPO_0)) gpo0(clk, cpu_addr, cpu_do, cpu_we, gpo_0);
    gpo #(.addr(`ADDR_GPO_1)) gpo1(clk, cpu_addr, cpu_do, cpu_we, gpo_1);
    gpo #(.addr(`ADDR_GPO_2)) gpo2(clk, cpu_addr, cpu_do, cpu_we, gpo_2);
    gpo #(.addr(`ADDR_GPO_3)) gpo3(clk, cpu_addr, cpu_do, cpu_we, gpo_3);
    gpo #(.addr(`ADDR_GPO_4)) gpo4(clk, cpu_addr, cpu_do, cpu_we, gpo_4);
    gpo #(.addr(`ADDR_GPO_5)) gpo5(clk, cpu_addr, cpu_do, cpu_we, gpo_5);
    gpo #(.addr(`ADDR_GPO_6)) gpo6(clk, cpu_addr, cpu_do, cpu_we, gpo_6);
    gpo #(.addr(`ADDR_GPO_7)) gpo7(clk, cpu_addr, cpu_do, cpu_we, gpo_7);

    // ----------------------------------------------------
    //                      UART
    // ----------------------------------------------------

    wire       uart_rst      = booting ? boot_rst      : cpu_rst;
    wire       uart_transmit = booting ? boot_transmit : 'b0;
    wire [7:0] uart_tx_data  = booting ? boot_tx_data  : 'b0;
    wire [7:0] uart_rx_data;
    wire       uart_rx_done;
    wire       uart_tx_done;

    uart uart(
        .sys_clk(clk),
        .sys_rst(uart_rst),
        .uart_rx(uart_rxd),
        .uart_tx(uart_txd),
        .divisor(50000000/115200/16),
        .rx_data(uart_rx_data),
        .tx_data(uart_tx_data),
        .rx_done(uart_rx_done),
        .tx_done(uart_tx_done),
        .tx_wr(uart_transmit)
    );

    // ----------------------------------------------------
    //                  BOOTLOADER
    // ----------------------------------------------------

    wire boot_rst;
    wire [15:0] boot_addr;
    wire [7:0]  boot_data;
    wire [7:0]  boot_tx_data;
    wire        boot_transmit;

    bootloader bootloader(
        .clk(clk),
        .rx_data(uart_rx_data),
        .tx_data(boot_tx_data),
        .rx_done(uart_rx_done),
        .tx_done(uart_tx_done),
        .transmit(boot_transmit),
        .ram_addr(boot_addr),
        .ram_data(boot_data),
        .trigger(boot_trigger),
        .booting(booting),
        .cpu_rst(cpu_rst),
        .boot_rst(boot_rst)
    );

endmodule
