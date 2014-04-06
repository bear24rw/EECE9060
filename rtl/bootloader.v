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

    // ----------------------------------------------------
    //              RESET STATE MACHINE
    // ----------------------------------------------------

    // wait for the boot process to trigger then put the cpu
    // in reset, then reset the boot state machine, then wait
    // for the boot state machine to indicate we are finished
    // booting and then take the cpu out of reset

    `define S_BOOT_RESET_START  0
    `define S_BOOT_RESET_END    1
    `define S_WAIT_FOR_DONE     2
    `define S_CPU_RESET_START   3
    `define S_CPU_RESET_END     4

    reg [3:0] rst_state = `S_BOOT_RESET_START;

    reg done = 0;   // flag to indicate we are done booting

    always @(posedge clk) begin
        if (trigger) begin
            booting <= 1;
            boot_rst <= 0;
            cpu_rst <= 0;
            rst_state <= `S_BOOT_RESET_START;
        end else begin
            case (rst_state)

                `S_BOOT_RESET_START: begin
                    boot_rst <= 1;
                    rst_state <= `S_BOOT_RESET_END;
                end

                `S_BOOT_RESET_END: begin
                    boot_rst <= 0;
                    rst_state <= `S_WAIT_FOR_DONE;
                end

                `S_WAIT_FOR_DONE: begin
                    if (done) begin
                        booting <= 0;
                        rst_state <= `S_CPU_RESET_START;
                    end
                end

                `S_CPU_RESET_START: begin
                    cpu_rst <= 1;
                    rst_state <= `S_CPU_RESET_END;
                end

                `S_CPU_RESET_END: begin
                    cpu_rst <= 0;
                end
            endcase
        end
    end

    // ----------------------------------------------------
    //              ROM LOADING STATE MACHINE
    // ----------------------------------------------------

    `define S_RECV       3    // wait for data byte
    `define S_SEND       2    // request next data byte from uart
    `define S_WRITE      4    // write data to RAM
    `define S_WRITE_WAIT 5    // write data to RAM
    `define S_IDLE       1

    reg [3:0] state = `S_IDLE;

    always @(posedge clk) begin
        if (boot_rst) begin
            tx_data <= 0;
            transmit <= 0;
            state <= `S_RECV;
            ram_addr <= 0;
            done <= 0;
        end else begin
            case (state)

                `S_RECV: begin
                    // if we got a new byte, send it back to ACK.
                    if (rx_done) begin
                        tx_data <= rx_data;
                        ram_data <= rx_data;
                        transmit <= 1;
                        state <= `S_SEND;
                    end
                end

                `S_SEND: begin
                    transmit <= 0;
                    if (tx_done) begin
                        state <= `S_WRITE;
                    end
                end

                `S_WRITE: begin
                    if (ram_addr == (2**`RAM_ADDR_BITS)-1) begin
                        done <= 1;
                        state <= `S_IDLE;
                    end else begin
                        ram_addr <= ram_addr + 1;
                        state <= `S_RECV;
                    end
                end

            endcase
        end
    end

endmodule
