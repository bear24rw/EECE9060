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

    wire [15:0] ram_addr;
    wire [7:0]  ram_di;
    wire [7:0]  ram_do;
    wire        ram_we;

    wire [7:0] hex_0;
    wire [7:0] hex_1;
    wire [7:0] hex_2;
    wire [7:0] hex_3;

    soc soc(
        .clk(CLOCK_50),
        .boot_trigger(~KEY[0]),
        .booting(LEDR[9]),

        .ram_addr(ram_addr),
        .ram_di(ram_di),
        .ram_do(ram_do),
        .ram_we(ram_we),

        .gpi_0(SW[7:0]),
        .gpi_1({4'b0, KEY}),
        .gpi_2(),
        .gpi_3(),
        .gpi_4(),
        .gpi_5(),
        .gpi_6(),
        .gpi_7(),

        .gpo_0(LEDR[7:0]),
        .gpo_1(LEDG[7:0]),
        .gpo_2(hex_0),
        .gpo_3(hex_1),
        .gpo_4(hex_2),
        .gpo_5(hex_3),
        .gpo_6(),
        .gpo_7(),

        .uart_rxd(UART_RXD),
        .uart_txd(UART_TXD)
    );

    ram ram(
        .clk(CLOCK_50),
        .addr(ram_addr[`RAM_ADDR_BITS-1:0]),
        .we(ram_we),
        .do(ram_do),
        .di(ram_di)
    );

    //seven_seg s0(ram_addr[3:0], HEX0);
    //seven_seg s1(ram_addr[7:4], HEX1);
    //seven_seg s2(ram_addr[11:8], HEX2);
    //seven_seg s3(ram_addr[15:12], HEX3);
    seven_seg s0(hex_0, HEX0);
    seven_seg s1(hex_1, HEX1);
    seven_seg s2(hex_2, HEX2);
    seven_seg s3(hex_3, HEX3);

endmodule
