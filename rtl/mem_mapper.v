`include "constants.v"

module mem_mapper(
    input   [15:0]  addr,
    output  [7:0]   cpu_di,

    input   [7:0]   gpi_0,
    input   [7:0]   gpi_1,
    input   [7:0]   gpi_2,
    input   [7:0]   gpi_3,
    input   [7:0]   gpi_4,
    input   [7:0]   gpi_5,
    input   [7:0]   gpi_6,
    input   [7:0]   gpi_7,
    input   [7:0]   timer_do,
    input   [7:0]   ram_do
);

    assign cpu_di = (addr == `ADDR_GPI_0)    ? gpi_0    :
                    (addr == `ADDR_GPI_1)    ? gpi_1    :
                    (addr == `ADDR_GPI_2)    ? gpi_2    :
                    (addr == `ADDR_GPI_3)    ? gpi_3    :
                    (addr == `ADDR_GPI_4)    ? gpi_4    :
                    (addr == `ADDR_GPI_5)    ? gpi_5    :
                    (addr == `ADDR_GPI_6)    ? gpi_6    :
                    (addr == `ADDR_GPI_7)    ? gpi_7    :
                    (addr == `ADDR_TMR_TRIG) ? timer_do :
                    ram_do;

endmodule
