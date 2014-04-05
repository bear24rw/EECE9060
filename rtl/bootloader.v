module bootloader(
    input clk,
    input rst,

    input      [7:0]  rx_data,
    output reg [7:0]  tx_data,
    input             rx_done,
    input             tx_done,
    output reg        transmit,

    output reg [15:0] ram_addr,
    output reg  [7:0] ram_data
);

    // the receive line only goes high for one clock
    // cycle so we need to latch it. if we are currently
    // transmitting we obviously don't have a new byte yet

    reg new_byte = 0;

    always @(posedge rst, posedge transmit, posedge rx_done) begin
        if (rst)
            new_byte <= 0;
        else if (transmit)
            new_byte <= 0;
        else
            new_byte <= 1;
    end

    // the tx_done line only goes high for one clock
    // cycle so we need to latch it. if we are currently
    // transmitting we obviously haven't finished sending it

    reg tx_done_latched = 0;

    always @(posedge rst, posedge transmit, posedge tx_done) begin
        if (rst)
            tx_done_latched <= 0;
        else if (transmit)
            tx_done_latched <= 0;
        else
            tx_done_latched <= 1;
    end

    // ----------------------------------------------------
    //                 STATE MACHINE
    // ----------------------------------------------------

    `define S_REQUEST    1    // request next data byte from uart
    `define S_RECV       2    // wait for data byte
    `define S_WRITE      3    // write data to RAM
    `define S_WRITE_WAIT 4    // write data to RAM

    reg [3:0] state = 0;

    always @(posedge clk) begin
        if (rst) begin
            tx_data <= 0;
            transmit <= 0;
            state <= `S_REQUEST;
            ram_addr <= 0;
        end else begin
            case (state)
                // we want to request the next byte.
                // trigger the uart to transmit and
                // then go to RECV state to wait for
                // the data
                `S_REQUEST: begin
                    transmit <= 1;
                    state <= `S_RECV;
                end

                // clear the transmit flag so we only
                // transmit one byte. check to see if
                // we recieved a new byte
                `S_RECV: begin
                    transmit <= 0;

                    // if we got a new byte, send it back to ACK.
                    // go to WRITE to put it in flash
                    if (new_byte) begin
                        tx_data <= rx_data;
                        ram_data <= rx_data;
                        state <= `S_WRITE;
                    end
                end

                `S_WRITE: begin
                    ram_addr <= ram_addr + 1;
                    state <= `S_WRITE_WAIT;
                end

                `S_WRITE_WAIT: begin
                    if (tx_done_latched) begin
                        state <= `S_REQUEST;
                    end
                end
            endcase
        end
    end

endmodule
