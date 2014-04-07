`timescale 1ns/1ns

module top_tb;

    reg clock_50 = 0;

    always
        clock_50 = #10 ~clock_50;


    wire [9:0] ledr;
    wire [7:0] ledg;
    wire [7:0] hex0;
    wire [7:0] hex1;
    wire [7:0] hex2;
    wire [7:0] hex3;


    top top(
        .CLOCK_50(clock_50),
        .LEDR(ledr),
        .LEDG(ledg),
        .HEX0(hex0),
        .HEX1(hex1),
        .HEX2(hex2),
        .HEX3(hex3)
    );

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        $monitor("[%d] LEDR: %b LEDG: %b HEX: %x %x %x %x",
            $time, ledr, ledg,
            hex3, hex2, hex1, hex0
        );
        $readmemb("../tools/hex_count.txt", top_tb.top.ram.ram);
        #100 top_tb.top.soc.bootloader.booting = 0;
        #100 top_tb.top.soc.bootloader.cpu_rst = 0;
        #100 top_tb.top.soc.bootloader.cpu_rst = 1;
        #100 top_tb.top.soc.bootloader.cpu_rst = 0;
        #1000000;
        $finish;
    end

endmodule
