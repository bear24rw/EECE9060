module cpu_tb;

    reg cpu_clk = 0;
    reg rst = 0;

    // ----------------------------------------------------
    //                      CLOCK
    // ----------------------------------------------------

    always
        cpu_clk = #1 ~cpu_clk;

    // ----------------------------------------------------
    //                      CPU
    // ----------------------------------------------------

    wire [15:0] addr;
    wire [7:0] cpu_di;
    wire [7:0] cpu_do;
    wire [7:0] cpu_we;

    cpu cpu(
        .clk(cpu_clk),
        .rst(rst),
        .addr(addr),
        .di(cpu_di),
        .do(cpu_do),
        .we(cpu_we)
    );

    // ----------------------------------------------------
    //                      RAM
    // ----------------------------------------------------

    ram ram(
        .clk(cpu_clk),
        .addr(addr),
        .we(cpu_we),
        .do(cpu_di),
        .di(cpu_do)
    );

    /*
    initial begin
        $readmemh("test.rom", cpu_tb.ram.ram);
    end
    */

    // ----------------------------------------------------
    //                      SIM
    // ----------------------------------------------------

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, cpu_tb);
    end

    initial begin
        $monitor("rst: %d | addr: %x | di: %x | do: %x | we: %x",
            rst, addr,
            cpu_di, cpu_do,
            cpu_we);
        #100 rst = 0;
        #100 rst = 1;
        #100 rst = 0;
        #10000;
        $finish;
    end


endmodule
