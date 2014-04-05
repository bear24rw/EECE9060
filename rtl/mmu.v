`include "constants.v"

module mmu(
    input   [15:0]  addr,
    output  [7:0]   cpu_di,
    input   [7:0]   cpu_do,
    output  [7:0]   ram_di,
    input   [7:0]   ram_do,
    input   [7:0]   io_do,
    output  [7:0]   io_di
);

    assign cpu_di = (addr < `RESET_VECTOR) ? io_do : ram_do;
    assign ram_di = cpu_di;
    assign io_di  = cpu_do;

endmodule
