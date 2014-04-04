module cpu(
    input            clk,
    input            rst,
    output    [15:0] addr,
    input      [7:0] di,
    output reg [7:0] do,
    output           we
);
    `include "op_codes.v"

    // --------------------------------
    // Instruction Cycle State Machine
    // --------------------------------

    parameter FETCH_0 = 0;
    parameter FETCH_1 = 1;
    parameter FETCH_2 = 2;
    parameter FETCH_3 = 3;
    parameter FETCH_4 = 4;
    parameter FETCH_5 = 5;
    parameter DECODE  = 6;
    parameter EXECUTE = 7;
    parameter STORE   = 8;

    reg [8:0] state = FETCH_0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= FETCH_0;
        end else begin
            case (state)
                FETCH_0: state <= FETCH_1;
                FETCH_1: state <= FETCH_2;
                FETCH_2: state <= FETCH_3;
                FETCH_3: state <= FETCH_4;
                FETCH_4: state <= FETCH_5;
                FETCH_5: state <= DECODE;
                DECODE:  state <= EXECUTE;
                EXECUTE: state <= STORE;
                STORE:   state <= FETCH_0;
            endcase
        end
    end


    // --------------------------------
    //
    // --------------------------------

    reg [15:0] PC = 'b0;
    reg [31:0] IR = 'b0;
    reg [7:0] regs[0:255];
    reg [7:0] w_reg;

    wire [7:0]  op_code = IR[31:24];
    wire [7:0]  op_a    = IR[23:16];
    wire [7:0]  op_b    = IR[15:8];
    wire [7:0]  op_d    = IR[7:0];
    wire [15:0] d_addr  = IR[15:0];

    reg [15:0] i_addr = 'b0;
    reg get_data = 'b0;

    assign addr = get_data ? d_addr : i_addr;
    assign we = (op_code == ST) && (state == EXECUTE);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            PC <= 0;
            IR <= 0;
        end else begin
            i_addr <= PC + 1;
            case (state)
                FETCH_0: get_data <= 0;
                FETCH_1: IR[31:24] <= di;
                FETCH_2: IR[23:16] <= di;
                FETCH_3: IR[15:8]  <= di;
                FETCH_4: IR[7:0]   <= di;
                FETCH_5: get_data <= 1;

                DECODE: begin

                end

                EXECUTE: begin
                    case (op_code)
                        ST:   do <= regs[op_a];
                        LD:   regs[op_a] <= di;
                        LDI:  regs[op_a] <= op_b;
                        MOV:  regs[op_a] <= regs[op_b];

                        ADD:  regs[op_d] <= regs[op_a] + regs[op_b];
                        SUB:  regs[op_d] <= regs[op_a] - regs[op_b];
                        AND:  regs[op_d] <= regs[op_a] & regs[op_b];
                        OR:   regs[op_d] <= regs[op_a] | regs[op_b];
                        XOR:  regs[op_d] <= regs[op_a] ^ regs[op_b];
                        ROTL: regs[op_d] <= regs[op_a] << regs[op_b];
                        ROTR: regs[op_d] <= regs[op_a] >> regs[op_b];

                    endcase

                end

                STORE: begin

                    if (op_code != HALT) begin
                        PC <= PC + 4;
                    end
                end
            endcase
        end
    end


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            $display("[cpu] In reset");
        end else begin
            case (op_code)
                HALT: $display("[cpu] op_code: HALT");
                LD:   $display("[cpu] op_code: LD");
                ST:   $display("[cpu] op_code: ST");
                LDI:  $display("[cpu] op_code: LDI");
                MOV:  $display("[cpu] op_code: MOV");
                ADD:  $display("[cpu] op_code: ADD");
                SUB:  $display("[cpu] op_code: SUB");
                AND:  $display("[cpu] op_code: AND");
                OR:   $display("[cpu] op_code: OR");
                XOR:  $display("[cpu] op_code: XOR");
                ROTL: $display("[cpu] op_code: ROTL");
                ROTR: $display("[cpu] op_code: ROTR");
                JMP:  $display("[cpu] op_code: JMP");
                default: $display("[cpu] ERROR: Invalid op_code: %b", op_code);
            endcase
        end
    end

endmodule
