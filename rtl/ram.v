// http://www.altera.com/support/examples/verilog/ver-single-port-ram.html

module ram(
    input clk,
    input we,
    input [ADDR_BITS-1:0] addr,
    input [7:0] di,
    output [7:0] do,
    output [ADDR_BITS-1:0] cur_addr
);

    parameter WIDTH     = 8;    // 8 bits wide
    parameter ADDR_BITS = 13;   // 2**13 (8KB) deep

    reg [WIDTH-1:0] ram[(2**ADDR_BITS)-1:0];

    reg [ADDR_BITS-1:0] addr_reg = 0;

    always @(posedge clk) begin

        // if write enable store new value
        if (we) ram[addr] <= di;

        // save this addr so we can continue to output it
        addr_reg <= addr;

    end

    // continuous assignment implies read returns NEW data
    // this is the natural behavior of the TriMatrix memory
    // blocks in single port mode
    assign do = ram[addr_reg];

    assign cur_addr = addr_reg;
endmodule
