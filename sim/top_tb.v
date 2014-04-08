`timescale 1ns/1ns

module top_tb;

    reg clock_50 = 0;

    always
        clock_50 = #10 ~clock_50;

    top top(
        .CLOCK_50(clock_50)
    );

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        $monitor("[%d] LEDR: %b LEDG: %b HEX: %x %x %x %x",
            $time,
            top_tb.top.LEDR,
            top_tb.top.LEDG,
            top_tb.top.hex_3,
            top_tb.top.hex_2,
            top_tb.top.hex_1,
            top_tb.top.hex_0
        );
        $readmemb("../tools/seg_count.txt", top_tb.top.ram.ram);
        #100 top_tb.top.soc.bootloader.booting = 0;
        #100 top_tb.top.soc.bootloader.cpu_rst = 0;
        #100 top_tb.top.soc.bootloader.cpu_rst = 1;
        #100 top_tb.top.soc.bootloader.cpu_rst = 0;
        #100000;
        $finish;
    end

endmodule
