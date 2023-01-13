module riscvmulti(input logic clk,
    input logic reset, 
    input logic [6:0] op,
    input logic [2:0] funct3,
    input logic funct7b5,
    input logic Zero,
    output logic [1:0] immsrc,
    output logic [1:0] ALUSrcA, ALUSrcB,
    output logic [1:0] ResultSrc, 
    output logic AdrSrc,
    output logic [2:0] ALUControl,
    output logic IRWrite, PCWrite, 
    output logic RegWrite, MemWrite);

logic[1:0] ALUOp;
Main_FSM mfsm(clk, reset, op[6:0], Zero, PCWrite, IRWrite, RegWrite, MemWrite, ResultSrc[1:0], ALUSrcA[1:0], ALUSrcB[1:0], AdrSrc, ALUOp[1:0]);

aludec alu(op[5], ALUOp[1:0], funct3[2:0], funct7b5, ALUControl[2:0]);

instrdec ins(op[6:0], immsrc[1:0]);

endmodule

module Main_FSM(input logic clk,
   input logic reset,
   input logic[6:0] op,
   input logic Zero,
   output logic PCWrite, IRWrite,
   output logic RegWrite, MemWrite,
   output logic[1:0] ResultSrc,
   output logic[1:0] ALUSrcA, ALUSrcB,
   output logic AdrSrc,
   output logic[1:0] ALUOp);


logic[10:0] state, nextstate;
logic PCUpdate;
logic Branch;

parameter S0 = 11'b00000000001;
parameter S1 = 11'b00000000010;
parameter S2 = 11'b00000000100;
parameter S3 = 11'b00000001000;
parameter S4 = 11'b00000010000;
parameter S5 = 11'b00000100000;
parameter S6 = 11'b00001000000;
parameter S7 = 11'b00010000000;
parameter S8 = 11'b00100000000;
parameter S9 = 11'b01000000000;
parameter S10 = 11'b10000000000;

always_ff @(posedge clk, posedge reset)
    if (reset) state = S0;
    else       state = nextstate;

assign PCWrite = (Zero & Branch) | PCUpdate;


always_comb 
    begin
        case (state)
        S0 : begin
            Branch = 1'b0;
            PCUpdate = 1'b1;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            IRWrite = 1'b1;
            ResultSrc = 2'b10;
            ALUSrcA = 2'b0;
            ALUSrcB = 2'b10;
            AdrSrc = 1'b0;
            ALUOp = 2'b00;
            nextstate = S1;

        end

        S1 : begin
            Branch = 1'b0;
            PCUpdate = 1'b0;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            ResultSrc = 2'b0;
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b01;
            AdrSrc = 1'b0;
            ALUOp = 2'b0;
            if((op == 7'b0000011) || (op == 7'b0100011))begin
                nextstate = S2;
            end
            else if(op == 7'b0110011)begin
                nextstate = S6;
            end
            else if(op == 7'b0010011)begin
                nextstate = S8;
            end
            else if(op == 7'b1101111)begin
                nextstate = S9;
            end
            else if(op == 7'b1100011)begin
                nextstate = S10;
            end
            else begin
                nextstate = S0;
            end
        end

        S2 : begin
            Branch = 1'b0;
            PCUpdate = 1'b0;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            ResultSrc = 2'b0;
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b01;
            AdrSrc = 1'b0;
            ALUOp = 2'b0;
            if(op == 7'b0000011)begin
                nextstate = S3;
            end
            else if(op == 7'b0100011)begin
                nextstate = S5;
            end
            else begin
                nextstate = S0;
            end
        end

        S3 : begin
            Branch = 1'b0;
            PCUpdate = 1'b0;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            ResultSrc = 2'b0;
            ALUSrcA = 2'b0;
            ALUSrcB = 2'b0;
            AdrSrc = 1'b1;
            ALUOp = 2'b0;
            nextstate = S4;
        end

        S4 : begin
            Branch = 1'b0;
            PCUpdate = 1'b0;
            RegWrite = 1'b1;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            ResultSrc = 2'b01;
            ALUSrcA = 2'b0;
            ALUSrcB = 2'b0;
            AdrSrc = 1'b0;
            ALUOp = 2'b0;
            nextstate = S0;
        end

        S5 : begin
            Branch = 1'b0;
            PCUpdate = 1'b0;
            RegWrite = 1'b0;
            MemWrite = 1'b1;
            IRWrite = 1'b0;
            ResultSrc = 2'b00;
            ALUSrcA = 2'b0;
            ALUSrcB = 2'b0;
            AdrSrc = 1'b1;
            ALUOp = 2'b0;
            nextstate = S0;
        end

        S6 : begin
            Branch = 1'b0;
            PCUpdate = 1'b0;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            ResultSrc = 2'b00;
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b0;
            AdrSrc = 1'b0;
            ALUOp = 2'b10;
            nextstate = S7;
        end

        S7 : begin
            Branch = 1'b0;
            PCUpdate = 1'b0;
            RegWrite = 1'b1;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            ResultSrc = 2'b00;
            ALUSrcA = 2'b0;
            ALUSrcB = 2'b0;
            AdrSrc = 1'b0;
            ALUOp = 2'b0;
            nextstate = S0;
        end

        S8 : begin
            Branch = 1'b0;
            PCUpdate = 1'b0;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            ResultSrc = 2'b00;
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b01;
            AdrSrc = 1'b0;
            ALUOp = 2'b10;
            nextstate = S7;
        end

        S9 : begin
            Branch = 1'b0;
            PCUpdate = 1'b1;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            ResultSrc = 2'b00;
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            AdrSrc = 1'b0;
            ALUOp = 2'b0;
            nextstate = S7;
        end

        S10 : begin
            Branch = 1'b1;
            PCUpdate = 1'b0;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            IRWrite = 1'b0;
            ResultSrc = 2'b00;
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b0;
            AdrSrc = 1'b0;
            ALUOp = 2'b01;
            nextstate = S0;
        end

        default: begin
            nextstate = S0;
            end
        endcase
    end
endmodule

module aludec(input logic opb5,
    input logic[1:0] ALUOp,
    input logic[2:0] funct3,
    input logic      funct7b5,
    output logic[2:0] ALUControl);
logic RtypeSub;
assign RtypeSub = funct7b5 & opb5; // TRUE for R-type subtract instruction
always_comb
    case(ALUOp)
    2'b00: ALUControl = 3'b0000; // addition
    2'b01: ALUControl = 3'b0001; // subtraction
    default: case(funct3) // R-type or I-type ALU
            3'b000: if (RtypeSub) 
                        ALUControl = 3'b001; // sub
            else 
                    ALUControl = 3'b000; // add, addi
            3'b010: ALUControl = 3'b101; // slt, slti
            3'b110: ALUControl = 3'b011; // or, ori
            3'b111: ALUControl = 3'b010; // and, andi
            default: ALUControl = 3'b000; // ???
            endcase
    endcase
endmodule


module instrdec (input logic [6:0] op, 
    output logic [1:0] ImmSrc);
    always_comb
        case(op)
        7'b0110011: ImmSrc = 2'bxx; // R-type
        7'b0010011: ImmSrc = 2'b00; // I-type ALU
        7'b0000011: ImmSrc = 2'b00; // lw
        7'b0100011: ImmSrc = 2'b01; // sw
        7'b1100011: ImmSrc = 2'b10; // beq
        7'b1101111: ImmSrc = 2'b11; // jal
        default: ImmSrc = 2'bxx; // ???
    endcase
endmodule