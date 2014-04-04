module io(
    input clk,
    input rst,

    input     [15:0] addr,
    input            we,
    input  reg [7:0] do,
    input      [7:0] di,

    input      [9:0] switches,
    input      [3:0] keys,

    output reg [9:0] ledr,
    output reg [7:0] ledg,

    output reg [6:0] seg0,
    output reg [6:0] seg1,
    output reg [6:0] seg2,
    output reg [6:0] seg3,

    input      [7:0] uart_rxd_data,
    output reg [7:0] uart_txd_data,
    input            uart_rxd_done,
    input            uart_txd_done,
    output           uart_transmit
);

    reg [7:0] uart_control = 'b0;
    assign uart_transmit = uart_control[2];

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            ledr <= 'hAA;
            ledg <= 'hAA;
            seg0 <= 'hD;
            seg1 <= 'hE;
            seg2 <= 'hA;
            seg3 <= 'hD;
            uart_txd_data <= 'h0;
            uart_control <= 'h0;
        end else begin
            uart_control[0] <= uart_rxd_done;
            uart_control[1] <= uart_txd_done;
            if (we) begin
                case (addr)
                    `ADDR_LEDR: ledr <= di;
                    `ADDR_LEDG: ledg <= di;
                    `ADDR_SEG0: seg0 <= di;
                    `ADDR_SEG1: seg1 <= di;
                    `ADDR_SEG2: seg2 <= di;
                    `ADDR_SEG3: seg3 <= di;
                    `ADDR_UART_TXD: uart_txd_data <= di;
                    `ADDR_UART_CTL: uart_control[2] <= di[2];
                endcase
            end else begin
                case (addr)
                    `ADDR_KEY:      do <= {keys, 3'b0};
                    `ADDR_SW:       do <= switches[7:0];
                    `ADDR_UART_RXD: do <= uart_rxd_data;
                    `ADDR_UART_CTL: do <= uart_control;
                    default:        do <= 'b0;
                endcase
            end
        end
    end

endmodule
