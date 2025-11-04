`timescale 1ns / 1ps
`include "defines.sv"

module ControlUnit (
    // global signals
    input  logic        clk,
    input  logic        reset,
    // ROM side port
    input  logic [31:0] instrCode,
    // data path side port
    output logic        PCEn,
    output logic        regFileWe,
    output logic        aluSrcMuxSel,
    output logic [ 3:0] aluControl,
    output logic [ 2:0] RFWDSrcMuxSel,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    // data memory side port
    output logic [ 2:0] strb,
    output logic        busWe
);
    wire  [6:0] opcode = instrCode[6:0];
    wire  [3:0] operator = {instrCode[30], instrCode[14:12]};
    logic [9:0] signals;

    assign {PCEn, regFileWe, aluSrcMuxSel, busWe, RFWDSrcMuxSel, branch, jal, jalr} = signals;
    assign strb = instrCode[14:12];

    typedef enum {
        FETCH,
        DECODE,
        R_EXE,
        I_EXE,
        B_EXE,
        LU_EXE,
        AU_EXE,
        J_EXE,
        JL_EXE,
        S_EXE,
        S_MEM,
        L_EXE,
        L_MEM,
        L_WB
    } state_e;

    state_e state, next_state;


    // State register
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= FETCH;
        end else begin
            state <= next_state;
        end
    end

    // Next state logic
    always_comb begin
        next_state = state;
        case (state)
            FETCH:  next_state = DECODE;
            DECODE: begin 
                case(opcode)
                    `OP_TYPE_R: next_state = R_EXE;
                    `OP_TYPE_I: next_state = I_EXE;
                    `OP_TYPE_S: next_state = S_EXE;
                    `OP_TYPE_L: next_state = L_EXE;
                    `OP_TYPE_B: next_state = B_EXE;
                    `OP_TYPE_LU: next_state = LU_EXE;
                    `OP_TYPE_AU: next_state = AU_EXE;
                    `OP_TYPE_J: next_state = J_EXE;
                    `OP_TYPE_JL: next_state = JL_EXE;
                    default:    next_state = R_EXE;
                endcase
            end
            R_EXE:  next_state = FETCH;
            I_EXE:  next_state = FETCH;
            B_EXE:  next_state = FETCH;
            // LU-Type : IF -> ID -> EXE
            LU_EXE : next_state = FETCH;
            // AU-Type : IF -> ID -> EXE
            AU_EXE : next_state = FETCH;
            // J-Type : IF -> ID -> EXE
            J_EXE  : next_state = FETCH;
            // JL-Type : IF -> ID -> EXE
            JL_EXE : next_state = FETCH;
            // S-Type : IF -> ID -> EXE -> MEM
            S_EXE : next_state = S_MEM;
            S_MEM : next_state = FETCH;
            // L-Type : IF -> ID -> EXE -> MEM -> WB
            L_EXE : next_state = L_MEM;
            L_MEM : next_state = L_WB;
            L_WB  : next_state = FETCH;
            default: next_state = R_EXE;
        endcase
    end


    // Output logic
    always_comb begin
        signals = 10'b0;
        aluControl = `ADD;
        case (state)
            //{PCEn, regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel(3), branch, jal, jalr} 
            FETCH:  signals = 10'b1_0_0_0_000_0_0_0;   // PCEn = 1, regFileWe = 0, aluSrcMuxSel = 0, dataWe = 0, RFWDSrcMuxSel = 000, branch = 0, jal = 0, jalr = 0
            DECODE: signals = 10'b0_0_0_0_000_0_0_0;   // PCEn = 0, regFileWe = 0, aluSrcMuxSel = 0, dataWe = 0, RFWDSrcMuxSel = 000, branch = 0, jal = 0, jalr = 0
            R_EXE: begin
                signals = 10'b0_1_0_0_000_0_0_0;       // PCEn = 0, regFileWe = 1, aluSrcMuxSel = 0, dataWe = 0, RFWDSrcMuxSel = 000, branch = 0, jal = 0, jalr = 0
                aluControl = operator;
            end

            I_EXE: begin
                signals = 10'b0_1_1_0_000_0_0_0;       // PCEn = 0, regFileWe = 1, aluSrcMuxSel = 1, dataWe = 0, RFWDSrcMuxSel = 000, branch = 0, jal = 0, jalr = 0
                if (operator == 4'b1101) aluControl = operator;
                else aluControl = {1'b0, operator[2:0]};
            end

            B_EXE: begin                        
                signals = 10'b0_0_0_0_000_1_0_0;        // PCEn = 0, regFileWe = 0, aluSrcMuxSel = 0, dataWe = 0, RFWDSrcMuxSel = 000, branch = 1, jal = 0, jalr = 0
                aluControl = operator;
            end

            LU_EXE: begin
                signals = 10'b0_1_0_0_010_0_0_0;        // PCEn = 0, regFileWe = 1, aluSrcMuxSel = 0, dataWe = 0, RFWDSrcMuxSel = 010, branch = 0, jal = 0, jalr = 0
            end

            AU_EXE: begin
                signals = 10'b0_1_0_0_011_0_0_0;        // PCEn = 0, regFileWe = 1, aluSrcMuxSel = 0, dataWe = 0, RFWDSrcMuxSel = 011, branch = 0, jal = 0, jalr = 0
            end

            J_EXE: begin
                signals = 10'b0_1_0_0_100_0_1_0;        // PCEn = 0, regFileWe = 1, aluSrcMuxSel = 0, dataWe = 0, RFWDSrcMuxSel = 100, branch = 0, jal = 1, jalr = 0
            end

            JL_EXE: begin
                signals = 10'b0_1_1_0_100_0_1_1;       // PCEn = 0, regFileWe = 1, aluSrcMuxSel = 0, dataWe = 0, RFWDSrcMuxSel = 100, branch = 0, jal = 1, jalr = 1
            end

            S_EXE: begin
                signals = 10'b0_0_1_0_000_0_0_0;        // PCEn = 0, regFileWe = 0, aluSrcMuxSel = 1, dataWe = 1, RFWDSrcMuxSel = 000, branch = 0, jal = 0, jalr = 0
            end

            S_MEM: begin
                signals = 10'b0_0_0_1_000_0_0_0;        // PCEn = 0, regFileWe = 0, aluSrcMuxSel = 1, dataWe = 1, RFWDSrcMuxSel = 000, branch = 0, jal = 0, jalr = 0
            end

            L_EXE: begin
                signals = 10'b0_0_1_0_000_0_0_0;        // PCEn = 0, regFileWe = 0, aluSrcMuxSel = 1, dataWe = 0, RFWDSrcMuxSel = 001, branch = 0, jal = 0, jalr = 0
            end

            L_MEM: begin
                signals = 10'b0_0_0_0_001_0_0_0;        // PCEn = 0, regFileWe = 0, aluSrcMuxSel = 0, dataWe = 0, RFWDSrcMuxSel = 001, branch = 0, jal = 0, jalr = 0
            end

            L_WB: begin
                signals = 10'b0_1_0_0_001_0_0_0;       // PCEn = 0, regFileWe = 1, aluSrcMuxSel = 1, dataWe = 0, RFWDSrcMuxSel = 001, branch = 0, jal = 0, jalr = 0 
            end
        endcase
    end

    /*
    always_comb begin
        signals = 9'b0;
        case (opcode)
            //{regFileWe, aluSrcMuxSel, dataWe, RFWDSrcMuxSel(3), branch, jal, jalr} 
            `OP_TYPE_R:  signals = 9'b1_0_0_000_0_0_0;
            `OP_TYPE_I:  signals = 9'b1_1_0_000_0_0_0;
            `OP_TYPE_S:  signals = 9'b0_1_1_000_0_0_0;
            `OP_TYPE_L:  signals = 9'b1_1_0_001_0_0_0;
            `OP_TYPE_B:  signals = 9'b0_0_0_000_1_0_0;
            `OP_TYPE_LU: signals = 9'b1_0_0_010_0_0_0;
            `OP_TYPE_AU: signals = 9'b1_0_0_011_0_0_0;
            `OP_TYPE_J:  signals = 9'b1_0_0_100_0_1_0;
            `OP_TYPE_JL: signals = 9'b1_0_0_100_0_1_1;
        endcase
    end

    always_comb begin
        aluControl = `ADD;
        case (opcode)
            `OP_TYPE_R: aluControl = operator;
            `OP_TYPE_B: aluControl = operator;
            `OP_TYPE_I: begin
                if (operator == 4'b1101) aluControl = operator;
                else aluControl = {1'b0, operator[2:0]};
            end
        endcase
    end
    */
endmodule
