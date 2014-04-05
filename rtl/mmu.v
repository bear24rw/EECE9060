`include "constants.v"

module mmu(
    input   [15:0]  addr,
    output  [7:0]   cpu_di,
    input   [7:0]   cpu_do,
    output  [7:0]   ram_di,
    input   [7:0]   ram_do,
    input   [7:0]   io_do,
    output  [7:0]   io_di,
    input           boot_en,
    input   [7:0]   boot_data
);

    assign cpu_di = (addr < `RESET_VECTOR) ? io_do : ram_do;
    assign io_di  = cpu_do;
    assign ram_di = boot_en ? boot_data : cpu_di;

endmodule
