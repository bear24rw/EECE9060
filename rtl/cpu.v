`include "constants.v"

module cpu(
    input            clk,
    input            rst,
    output    [15:0] addr,
    input      [7:0] di,
    output reg [7:0] do,
    output           we
);

    // --------------------------------
    // Instruction Cycle State Machine
    // --------------------------------

    parameter FETCH_0 = 0;
    parameter FETCH_1 = 1;
    parameter FETCH_2 = 2;
    parameter FETCH_3 = 3;
    parameter FETCH_4 = 4;
    parameter DECODE  = 5;
    parameter FETCH_EX = 6;
    parameter EXECUTE = 7;
    parameter STORE   = 8;

    reg [7:0] state = FETCH_0;

    always @(posedge clk) begin
        if (rst) begin
            state <= FETCH_0;
        end else begin
            case (state)
                FETCH_0: state <= FETCH_1;
                FETCH_1: state <= FETCH_2;
                FETCH_2: state <= FETCH_3;
                FETCH_3: state <= FETCH_4;
                FETCH_4: state <= DECODE;
                DECODE:  state <= FETCH_EX;
                FETCH_EX:  state <= EXECUTE;
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
    wire [7:0]  op_d    = IR[23:16];
    wire [7:0]  op_a    = IR[15:8];
    wire [7:0]  op_b    = IR[7:0];
    wire [15:0] d_addr  = IR[15:0];
    wire [15:0] jmp_addr = IR[23:8];

    reg [15:0] i_addr = 'b0;
    reg get_data = 'b0;

    assign addr = get_data ? d_addr : i_addr;
    assign we = (op_code == `ST) && (state == STORE);


    always @(posedge clk) begin
        if (rst) begin
            i_addr <= `RESET_VECTOR;
        end else begin
            case (state)
                STORE:   i_addr <= PC + 0;
                FETCH_0: i_addr <= PC + 1;
                FETCH_1: i_addr <= PC + 2;
                FETCH_2: i_addr <= PC + 3;
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            PC <= `RESET_VECTOR;
            IR <= 0;
            do <= 0;
        end else begin
            case (state)

                FETCH_1: IR[31:24] <= di;
                FETCH_2: IR[23:16] <= di;
                FETCH_3: IR[15:8]  <= di;
                FETCH_4: IR[7:0]   <= di;

                DECODE: begin
                    get_data <= 1;
                    if (op_code != `HALT) begin
                        PC <= PC + 4;
                    end
                end

                EXECUTE: begin
                    case (op_code)
                        `ST:   do <= regs[op_d];
                        `LD:   regs[op_d] <= di;
                        `LDI:  regs[op_d] <= op_a;
                        `MOV:  regs[op_d] <= regs[op_a];

                        `ADD:  regs[op_d] <= regs[op_a] + regs[op_b];
                        `SUB:  regs[op_d] <= regs[op_a] - regs[op_b];
                        `AND:  regs[op_d] <= regs[op_a] & regs[op_b];
                        `OR:   regs[op_d] <= regs[op_a] | regs[op_b];
                        `XOR:  regs[op_d] <= regs[op_a] ^ regs[op_b];
                        `ROTL: regs[op_d] <= regs[op_a] << regs[op_b];
                        `ROTR: regs[op_d] <= regs[op_a] >> regs[op_b];

                        `JMP:  PC <= jmp_addr;
                    endcase

                end

                STORE: begin
                    get_data <= 0;
                end
            endcase
        end
    end


    /*
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            $display("[cpu] In reset");
        end else begin
            if (state == DECODE) begin
                case (op_code)
                    HALT: $display("[cpu] PC: %d IR: %b op_code: HALT" , PC, IR);
                    LD:   $display("[cpu] PC: %d IR: %b op_code: LD"   , PC, IR);
                    ST:   $display("[cpu] PC: %d IR: %b op_code: ST (%d = r[%d])", PC, IR, d_addr, op_d);
                    LDI:  $display("[cpu] PC: %d IR: %b op_code: LDI (r[%d] = %d", PC, IR, op_d, op_a);
                    MOV:  $display("[cpu] PC: %d IR: %b op_code: MOV"  , PC, IR);
                    ADD:  $display("[cpu] PC: %d IR: %b op_code: ADD (r[%d]: %d + r[%d]: %d"  , PC, IR, op_a, regs[op_a], op_b, regs[op_b]);
                    SUB:  $display("[cpu] PC: %d IR: %b op_code: SUB"  , PC, IR);
                    AND:  $display("[cpu] PC: %d IR: %b op_code: AND"  , PC, IR);
                    OR:   $display("[cpu] PC: %d IR: %b op_code: OR"   , PC, IR);
                    XOR:  $display("[cpu] PC: %d IR: %b op_code: XOR"  , PC, IR);
                    ROTL: $display("[cpu] PC: %d IR: %b op_code: ROTL" , PC, IR);
                    ROTR: $display("[cpu] PC: %d IR: %b op_code: ROTR" , PC, IR);
                    JMP:  $display("[cpu] PC: %d IR: %b op_code: JMP"  , PC, IR);
                    default: $display("[cpu] ERROR: Invalid op_code: %b", op_code);
                endcase
            end
        end
    end
    */

    /*
    always @(posedge clk) begin
        if (rst == 0) begin
            case (state)
                //FETCH_0: $display("[cpu] [F0] PC: %d i_addr: %d di: %b", PC, i_addr, di);
                FETCH_1: $display("[cpu] [F1] PC: %d i_addr: %d di: %b", PC, i_addr, di);
                FETCH_2: $display("[cpu] [F2] PC: %d i_addr: %d di: %b", PC, i_addr, di);
                FETCH_3: $display("[cpu] [F3] PC: %d i_addr: %d di: %b", PC, i_addr, di);
                FETCH_4: $display("[cpu] [F4] PC: %d i_addr: %d di: %b", PC, i_addr, di);
            endcase
        end
    end
    */


endmodule
