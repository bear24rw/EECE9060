`include "constants.v"

module io(
    input clk,
    input rst,

    input     [15:0] addr,
    input            we,
    output reg [7:0] do,
    input      [7:0] di,

    input      [7:0] timer_do,
    input      [9:0] switches,
    input      [3:0] keys,

    output reg [9:0] ledr,
    output reg [7:0] ledg,

    output reg [6:0] seg0,
    output reg [6:0] seg1,
    output reg [6:0] seg2,
    output reg [6:0] seg3,

    input      [7:0] uart_rxd_data,
    output     [7:0] uart_txd_data,
    input            uart_rxd_done,
    input            uart_txd_done,
    output           uart_transmit,

    input      [7:0] boot_tx_data,
    input            boot_transmit,
    input            booting
);

    reg [7:0] uart_control = 0;
    reg [7:0] tx_data = 0;

    assign uart_transmit = booting ? boot_transmit : uart_control[2];
    assign uart_txd_data = booting ? boot_tx_data  : tx_data;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            ledr <= 'hAA;
            ledg <= 'hAA;
            seg0 <= 'hD;
            seg1 <= 'hA;
            seg2 <= 'hE;
            seg3 <= 'hD;
            tx_data <= 'h0;
            uart_control <= 'h0;
        end else begin
            uart_control[0] <= uart_rxd_done;
            uart_control[1] <= uart_txd_done;
            if (we) begin
                case (addr)
                    `ADDR_LEDR: ledr <= di;
                    `ADDR_LEDG: ledg <= di;
                    `ADDR_SEG0: seg0 <= di[6:0];
                    `ADDR_SEG1: seg1 <= di[6:0];
                    `ADDR_SEG2: seg2 <= di[6:0];
                    `ADDR_SEG3: seg3 <= di[6:0];
                    `ADDR_UART_TXD: tx_data <= di;
                    `ADDR_UART_CTL: uart_control[2] <= di[2];
                endcase
            end else begin
                case (addr)
                    `ADDR_KEY:      do <= {keys, 3'b0};
                    `ADDR_SW:       do <= switches[7:0];
                    `ADDR_UART_RXD: do <= uart_rxd_data;
                    `ADDR_UART_CTL: do <= uart_control;
                    `ADDR_TMR_TRIG: do <= timer_do;
                    default:        do <= 'hFA;
                endcase
            end
        end
    end

endmodule
