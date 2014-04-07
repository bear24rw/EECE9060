module gpo(
    input clk,
    input [15:0] cpu_addr,
    input [7:0]  cpu_do,
    input        cpu_we,
    output reg [7:0] do
);

    initial do = 0;

    parameter addr = 0;

    always @(posedge clk) begin
        if (cpu_we && (cpu_addr == addr)) begin
            do <= cpu_do;
        end
    end

endmodule
