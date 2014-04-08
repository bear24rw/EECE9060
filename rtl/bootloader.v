`include "constants.v"

module bootloader(
    input clk,

    input      [7:0]  rx_data,
    output reg [7:0]  tx_data,
    input             rx_done,
    input             tx_done,
    output reg        transmit,

    output reg [15:0] ram_addr,
    output reg  [7:0] ram_data,

    input             trigger,
    output reg        booting,
    output reg        cpu_rst,
    output reg        boot_rst
);

    initial booting = 1;
    initial cpu_rst = 0;
    initial boot_rst = 0;

    // ----------------------------------------------------
    //              ROM LOADING STATE MACHINE
    // ----------------------------------------------------

    localparam S_BOOT_RST_H     = 0;    // pull boot reset flag high
    localparam S_BOOT_RST_L     = 1;    // pull boot reset flag low
    localparam S_RECV           = 2;    // wait for data byte
    localparam S_SEND           = 3;    // send that back back to ACK
    localparam S_WRITE          = 4;    // write data to RAM
    localparam S_CPU_RST_H      = 5;    // pull cpu reset high
    localparam S_CPU_RST_L      = 6;    // pull cpu reset low
    localparam S_DONE           = 7;    // idle

    reg [3:0] state = S_DONE;

    always @(posedge clk) begin
        if (trigger) begin
            boot_rst <= 0;
            booting <= 1;
            cpu_rst <= 0;
            ram_addr <= 0;
            state <= S_BOOT_RST_H;
            transmit <= 0;
            tx_data <= 0;
        end else begin
            case (state)

                S_BOOT_RST_H: begin
                    boot_rst <= 1;
                    state <= S_BOOT_RST_L;
                end

                S_BOOT_RST_L: begin
                    boot_rst <= 0;
                    state <= S_RECV;
                end

                S_RECV: begin
                    if (rx_done) begin
                        tx_data <= rx_data;
                        ram_data <= rx_data;
                        transmit <= 1;
                        state <= S_SEND;
                    end
                end

                S_SEND: begin
                    transmit <= 0;
                    if (tx_done) begin
                        state <= S_WRITE;
                    end
                end

                S_WRITE: begin
                    if (ram_addr == (2**`RAM_ADDR_BITS)-1) begin
                        state <= S_CPU_RST_H;
                    end else begin
                        ram_addr <= ram_addr + 1;
                        state <= S_RECV;
                    end
                end

                S_CPU_RST_H: begin
                    cpu_rst <= 1;
                    booting <= 0;
                    state <= S_CPU_RST_L;
                end

                S_CPU_RST_L: begin
                    cpu_rst <= 0;
                end

            endcase
        end
    end

endmodule
