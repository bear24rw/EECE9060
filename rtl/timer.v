`include "constants.v"

module timer(
    input clk,
    input rst,

    input [15:0] addr,
    input we,
    input [7:0] di,
    output [7:0] do
);

    // ----------------------------------------------------
    //                  TRIGGER LEVEL
    // ----------------------------------------------------

    // default the timer to trigger every 100ms
    // 50Mhz clock = 20ns
    // 100ms / 20ns = 5*10^6 = 00 4C 4B 40

    `ifndef SIMULATION
        localparam DEFAULT_3 = 8'h00;
        localparam DEFAULT_2 = 8'h4C;
        localparam DEFAULT_1 = 8'h4B;
        localparam DEFAULT_0 = 8'h40;
    `else
        localparam DEFAULT_3 = 8'h00;
        localparam DEFAULT_2 = 8'h00;
        localparam DEFAULT_1 = 8'h00;
        localparam DEFAULT_0 = 8'h40;
    `endif

    reg [7:0] byte_3 = DEFAULT_3;
    reg [7:0] byte_2 = DEFAULT_2;
    reg [7:0] byte_1 = DEFAULT_1;
    reg [7:0] byte_0 = DEFAULT_0;

    wire [31:0] trigger_value = {byte_3, byte_2, byte_1, byte_0};

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            byte_3 <= DEFAULT_3;
            byte_2 <= DEFAULT_2;
            byte_1 <= DEFAULT_1;
            byte_0 <= DEFAULT_0;
        end else begin
            if (we && (addr == `ADDR_TMR_3)) begin byte_3 <= di; end
            if (we && (addr == `ADDR_TMR_2)) begin byte_2 <= di; end
            if (we && (addr == `ADDR_TMR_1)) begin byte_1 <= di; end
            if (we && (addr == `ADDR_TMR_0)) begin byte_0 <= di; end
        end
    end

    // ----------------------------------------------------
    //                      COUNTER
    // ----------------------------------------------------

    reg [31:0] count = 0;
    reg triggered = 0;
    assign do = {7'b0, triggered};

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            triggered <= 0;
        end else begin
            if (count == trigger_value) begin
                triggered <= 1;
                count <= 0;
            end else if (we && (addr == `ADDR_TMR_RST)) begin
                count <= 0;
                triggered <= 0;
            end else begin
                count <= count + 1;
            end
        end
    end

endmodule
