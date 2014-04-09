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
    parameter DECODE  = 4;
    parameter EXECUTE = 5;
    parameter STORE   = 6;

    reg [7:0] state = FETCH_0;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= STORE;
        end else begin
            case (state)
                FETCH_0: state <= FETCH_1;
                FETCH_1: state <= FETCH_2;
                FETCH_2: state <= FETCH_3;
                FETCH_3: state <= DECODE;
                DECODE:  state <= EXECUTE;
                EXECUTE: state <= STORE;
                STORE:   state <= FETCH_0;
            endcase
        end
    end


    // --------------------------------
    //      Internal registers
    // --------------------------------

    reg [15:0] PC = `RESET_VECTOR;
    reg [31:0] IR = 'b0;
    reg [7:0] regs[0:255];
    reg [7:0] w_reg;

    wire [7:0]  op_code = IR[31:24];
    wire [7:0]  op_d    = IR[23:16];
    wire [7:0]  op_a    = IR[15:8];
    wire [7:0]  op_b    = IR[7:0];
    wire [15:0] d_addr  = IR[15:0];
    wire [15:0] jmp_addr = IR[23:8];
    wire [15:0] br_addr = IR[15:0];

    reg [15:0] i_addr = 'b0;
    reg get_data = 'b0;

    assign addr = get_data ? d_addr : i_addr;
    assign we = (op_code == `OP_ST || op_code == `OP_STL) && (state == STORE);

    // ---------------------------------
    // Instruction address state machine
    // ---------------------------------

    always @(posedge clk, posedge rst) begin
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

    // ---------------------------------
    //      Execution state machine
    // ---------------------------------

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            PC <= `RESET_VECTOR;
            IR <= 0;
            do <= 0;
            get_data <= 0;
        end else begin
            case (state)

                FETCH_0: IR[31:24] <= di;
                FETCH_1: IR[23:16] <= di;
                FETCH_2: IR[15:8]  <= di;
                FETCH_3: IR[7:0]   <= di;

                DECODE: begin
                    get_data <= 1;
                    if (op_code != `OP_HALT) begin
                        PC <= PC + 4;
                    end
                end

                EXECUTE: begin
                    case (op_code)
                        `OP_ST:   do <= regs[op_d];
                        `OP_STL:  do <= op_d;
                        `OP_LD:   regs[op_d] <= di;
                        `OP_LDL:  regs[op_d] <= op_a;
                        `OP_MOV:  regs[op_d] <= regs[op_a];

                        `OP_ADD:  regs[op_d] <= regs[op_a] + regs[op_b];
                        `OP_SUB:  regs[op_d] <= regs[op_a] - regs[op_b];
                        `OP_AND:  regs[op_d] <= regs[op_a] & regs[op_b];
                        `OP_OR:   regs[op_d] <= regs[op_a] | regs[op_b];
                        `OP_XOR:  regs[op_d] <= regs[op_a] ^ regs[op_b];
                        `OP_SFL:  regs[op_d] <= regs[op_a] << regs[op_b];
                        `OP_SFR:  regs[op_d] <= regs[op_a] >> regs[op_b];
                        `OP_INC:  regs[op_d] <= regs[op_d] + 1;
                        `OP_DEC:  regs[op_d] <= regs[op_d] - 1;
                        `OP_EQL:  regs[op_d] <= regs[op_a] == regs[op_b];
                        `OP_GTH:  regs[op_d] <= regs[op_a] > regs[op_b];
                        `OP_LTH:  regs[op_d] <= regs[op_a] < regs[op_b];
                        `OP_INV:  regs[op_d] <= ~regs[op_a];

                        `OP_BRZ:  if (regs[op_d] == 0) PC <= br_addr;
                        `OP_BRNZ: if (regs[op_d] != 0) PC <= br_addr;

                        `OP_JMP:  PC <= jmp_addr;
                    endcase

                end

                STORE: begin
                    get_data <= 0;
                end
            endcase
        end
    end

    // ---------------------------------
    //     Simulation Debug Message
    // ---------------------------------

    /*
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            $display("[cpu] In reset");
        end else begin
            if (state == DECODE) begin
                case (op_code)
                    `OP_HALT: $display("[cpu] [decode] PC: %d IR: %x op_code: HALT" , PC, IR);
                    `OP_LD:   $display("[cpu] [decode] PC: %d IR: %x op_code: LD (r[%x] = M[%x]", PC, IR, op_d, d_addr);
                    `OP_ST:   $display("[cpu] [decode] PC: %d IR: %x op_code: ST (%d = r[%d])", PC, IR, d_addr, op_d);
                    `OP_STL:  $display("[cpu] [decode] PC: %d IR: %x op_code: STL (%d = %d)", PC, IR, d_addr, op_d);
                    `OP_LDL:  $display("[cpu] [decode] PC: %d IR: %x op_code: LDL (r[%d] = %d", PC, IR, op_d, op_a);
                    `OP_MOV:  $display("[cpu] [decode] PC: %d IR: %x op_code: MOV"  , PC, IR);
                    `OP_ADD:  $display("[cpu] [decode] PC: %d IR: %x op_code: ADD (r[%d]: %d + r[%d]: %d"  , PC, IR, op_a, regs[op_a], op_b, regs[op_b]);
                    `OP_SUB:  $display("[cpu] [decode] PC: %d IR: %x op_code: SUB"  , PC, IR);
                    `OP_AND:  $display("[cpu] [decode] PC: %d IR: %x op_code: AND"  , PC, IR);
                    `OP_OR:   $display("[cpu] [decode] PC: %d IR: %x op_code: OR"   , PC, IR);
                    `OP_XOR:  $display("[cpu] [decode] PC: %d IR: %x op_code: XOR"  , PC, IR);
                    `OP_SFL:  $display("[cpu] [decode] PC: %d IR: %x op_code: SFL" , PC, IR);
                    `OP_SFR:  $display("[cpu] [decode] PC: %d IR: %x op_code: SFR" , PC, IR);
                    `OP_INC:  $display("[cpu] [decode] PC: %d IR: %x op_code: INC", PC, IR);
                    `OP_DEC:  $display("[cpu] [decode] PC: %d IR: %x op_code: DEC", PC, IR);
                    `OP_EQL:  $display("[cpu] [decode] PC: %d IR: %x op_code: EQL", PC, IR);
                    `OP_GTH:  $display("[cpu] [decode] PC: %d IR: %x op_code: GTH", PC, IR);
                    `OP_LTH:  $display("[cpu] [decode] PC: %d IR: %x op_code: LTH", PC, IR);
                    `OP_BRZ:  $display("[cpu] [decode] PC: %d IR: %x op_code: BRZ", PC, IR);
                    `OP_BRNZ: $display("[cpu] [decode] PC: %d IR: %x op_code: BRNZ", PC, IR);
                    `OP_JMP:  $display("[cpu] [decode] PC: %d IR: %x op_code: JMP"  , PC, IR);
                    default:  $display("[cpu] [decode] ERROR: Invalid op_code: %b (%d) IR: %b", op_code, op_code, IR);
                endcase
            end
        end
    end

    always @(posedge clk) begin
        if (state == EXECUTE) begin
            case (op_code)
                `OP_LD: $display("[cpu] [exec] regs[%x] = %x", op_d, di);
                `OP_JMP: $display("[cpu] [exec] jumping to: %x", jmp_addr);
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst == 0) begin
            case (state)
                FETCH_0: $display("[cpu] [F0] PC: %d i_addr: %d di: %x", PC, i_addr, di);
                FETCH_1: $display("[cpu] [F1] PC: %d i_addr: %d di: %x", PC, i_addr, di);
                FETCH_2: $display("[cpu] [F2] PC: %d i_addr: %d di: %x", PC, i_addr, di);
                FETCH_3: $display("[cpu] [F3] PC: %d i_addr: %d di: %x", PC, i_addr, di);
            endcase
        end
    end
    */

endmodule
