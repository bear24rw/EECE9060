module clk_div(
    input clk_in,
    output reg clk_out = 0
);

    // default the clock divider to 1Hz
    // the DE1 has a 50MHz oscillator so
    // toggle every 25 million clocks
    parameter COUNT = 25000000;

    // register needs to be ln(25000000)/ln(2)
    // bits wide to handle 1Hz
    reg [24:0] counter = 0;

    always @(posedge clk_in) begin

        // if we have counted up to our desired value
        if (counter == COUNT) begin
            clk_out <= ~clk_out;    // toggle the output clock
            counter <= 0;           // reset the counter
        end else begin
            counter <= counter + 1; // increment the counter every pulse
        end

    end

endmodule
