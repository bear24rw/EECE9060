`timescale 1ns/1ns

module top_tb;

    reg clock_50 = 0;

    always
        clock_50 = #10 ~clock_50;


    wire [9:0] ledr;
    wire [7:0] ledg;

    top top(
        .CLOCK_50(clock_50),
        .LEDR(ledr),
        .LEDG(ledg)
    );

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        $monitor("[%d] LEDR: %b LEDG: %b timer: %x/%x trigger: %x",
            $time,
            ledr,
            ledg,
            top_tb.top.soc.timer.count,
            top_tb.top.soc.timer.trigger_value,
            top_tb.top.soc.timer.triggered
        );
        $readmemb("../tools/blink_1hz.txt", top_tb.top.ram.ram);
        #100 top_tb.top.soc.bootloader.booting = 0;
        #100 top_tb.top.soc.bootloader.cpu_rst = 0;
        #100 top_tb.top.soc.bootloader.cpu_rst = 1;
        #100 top_tb.top.soc.bootloader.cpu_rst = 0;
        #100000;
        $finish;
    end

endmodule
