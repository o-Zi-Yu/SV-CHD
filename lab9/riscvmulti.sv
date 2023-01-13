module riscvmulticycle(input  logic        clk, reset, 
    output logic [31:0] WriteData, DataAdr, 
    output logic        MemWrite);

logic Adrsrc;
logic[31:0] ReadData;

riscvmulti rvmulti(clk, reset, MemWrite, WriteData, Adrsrc, DataAdr, ReadData);
dmem     mem(clk, MemWrite, Adrsrc, DataAdr, WriteData, ReadData);


endmodule

module riscvmulti(input  logic        clk, reset,
          output logic        MemWrite,
          output logic [31:0] WriteData,
          output logic Adrsrc,
          output logic [31:0] Adr,
          input  logic [31:0] ReadData);

logic       irwrite , pcwrite, regwrite, Zero;
logic [1:0] ResultSrc, ImmSrc, alusrca, alusrcb;
logic [2:0] ALUControl;
logic [31:0] Instr;


datapath   dp(clk, reset, pcwrite, Adrsrc, irwrite, ResultSrc, ALUControl, alusrca, alusrcb, ImmSrc, regwrite, ReadData, Zero, Adr, WriteData, Instr);
controller ctrl(clk, reset, Instr[6:0], Instr[14:12], Instr[30], Zero, ImmSrc, alusrca, alusrcb, ResultSrc, Adrsrc, ALUControl, irwrite, pcwrite, regwrite, MemWrite);

endmodule

module datapath(input logic clk,
         input logic reset,
         input logic pcwrite,            
         input logic adrsrc,
         input logic irwrite,
         input logic[1:0] resultsrc,
         input logic[2:0] ALUControl,
         input logic[1:0] alusrca,
         input logic[1:0] alusrcb,
         input logic[1:0] immsrc,
         input logic regwrite,
         input logic [31:0] ReadData, 
         output logic zero,
         output logic [31:0] Adr,
         output logic[31:0] WriteData,
         output logic[31:0] Instr
         );

logic [31:0] PCNext, OldPC; 
logic [31:0] Data; 
logic [31:0] ImmExt;
logic [31:0] rd1; 
logic [31:0] rd2; 
logic [31:0] A; 
logic [31:0] SrcA, SrcB;
logic [31:0] ALUout; 
logic [31:0] Result; 
logic[31:0] ALUResult;
logic[31:0] PC;

//PC+data logic
assign PCNext = Result;
pcenable PCreg(clk, reset, pcwrite, PCNext, PC);
mux2   PCMUX(PC, Result, adrsrc, Adr);
instupdate Instreg(clk, reset, irwrite, PC, ReadData, OldPC, Instr);
dff  readdata(clk, reset, ReadData, Data);

//RF logic
regfile rf(clk, regwrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, rd1, rd2);
extend  ext(Instr[31:7], immsrc, ImmExt);
dff2  rfreg(clk, reset, rd1, rd2, A, WriteData);

//ALU logic
mux3 ALU_MUXa(PC, OldPC, A, alusrca, SrcA);
mux3 ALU_MUXb(WriteData, ImmExt, 32'd4, alusrcb, SrcB);
alu  alu(SrcA, SrcB, ALUControl, ALUResult, zero);

//result logic
dff aluoutreg(clk, reset, ALUResult, ALUout);
mux3  resultmux(ALUout, Data, ALUResult, resultsrc, Result);

endmodule

module regfile(input  logic        clk, 
        input  logic        we3, 
        input  logic [ 4:0] a1, a2, a3, 
        input  logic [31:0] wd3, 
        output logic [31:0] rd1, rd2);

logic [31:0] rf[31:0];

// three ported register file
// read two ports combinationally (A1/RD1, A2/RD2)
// write third port on rising edge of clock (A3/WD3/WE3)
// register 0 hardwired to 0

always_ff @(posedge clk)
if (we3) rf[a3] <= wd3;	

assign rd1 = (a1 != 0) ? rf[a1] : 0;
assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

module extend(input  logic [31:7] instr,
       input  logic [1:0]  immsrc,
       output logic [31:0] immext);

always_comb
case(immsrc) 
        // I-type 
2'b00:   immext = {{20{instr[31]}}, instr[31:20]};  
        // S-type (stores)
2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};  
        // B-type (branches)
2'b10:   immext = {{19{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        // J-type (jal)
2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
       //  U-type
default: immext = 32'bx; // undefined
endcase             
endmodule


module dmem(input  logic clk, we,
      input  logic adrsrc,
      input  logic [31:0] a, wd,
      output logic [31:0] rd);

    logic [31:0] RAM[63:0];
    logic [31:0] dRAM[63:0];

    initial
    $readmemh("riscvtest.txt",RAM);

    assign rd = (adrsrc == 1'b0) ? RAM[a[31:2]] : dRAM[a[31:2]];

    always_ff @(posedge clk)
        if (we) dRAM[a[31:2]] <= wd;
endmodule

module mux2(input  logic [31:0] d0, d1, 
     input  logic             s, 
     output logic [31:0] y);

    assign y = s ? d1 : d0; 
endmodule

module mux3(input  logic [31:0] d0, d1, d2,
     input  logic [1:0]       s, 
     output logic [31:0] y);

    assign y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule


module pcenable(input logic clk,
    input logic reset,
    input logic en,
    input logic[31:0] d1,
    output logic[31:0] d2);

  always_ff@(posedge clk or posedge reset)
      begin
      if(reset)begin
       d2 <= 32'b0;
      end

      else begin
       if(en == 1'b1)begin
            d2 <= d1;
       end

       else begin
            d2 <= d2;
       end
      end
  end

endmodule


module instupdate(input logic clk,
    input logic reset,
    input logic en,
    input logic[31:0] d1, d2,
    output logic[31:0] d3, d4);

always_ff@(posedge clk or posedge reset)
begin
  if(reset)begin
   d3 <= 32'b0;
   d4 <= 32'b0;
  end
  else begin
   if(en == 1'b1)begin
        d3 <= d1;
        d4 <= d2;
   end

   else begin
        d3 <= d3;
        d4 <= d4;
   end
  end
end

endmodule


module dff(input logic clk,
  input logic reset,
  input logic[31:0] d1,
  output logic[31:0] d2);

  always_ff@(posedge clk)
      begin
      if(reset)begin
      d2 <= 32'b0;
      end

      else begin
      d2 <= d1;
      end
  end

endmodule

module dff2(input logic clk,
     input logic reset,
     input logic[31:0] d1, d2,
     output logic[31:0] d3, d4);
         
always_ff @(posedge clk) 
begin
if(reset)begin
d3 <= 32'b0;
d4 <= 32'b0;
end

else begin
d3 <= d1;
d4 <= d2;
end

end
endmodule



module controller(input logic clk,
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
    2'b00: ALUControl = 3'b000; // addition
    2'b01: ALUControl = 3'b001; // subtraction
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
    
    
   
module alu(input  logic [31:0] a, b,
    input  logic [2:0]  alucontrol,
    output logic [31:0] result,
    output logic        zero);
    
    logic [31:0] condinvb, sum;
    logic        v;              // overflow
    logic        isAddSub;       // true when is add or subtract operation
    
    assign condinvb = alucontrol[0] ? ~b : b;
    assign sum = a + condinvb + alucontrol[0];
    assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
          ~alucontrol[1] & alucontrol[0];
    
    always_comb
    case (alucontrol)
    3'b000:  result = sum;                 // add
    3'b001:  result = sum;                 // subtract
    3'b010:  result = a & b;               // and
    3'b011:  result = a | b;         // or
    3'b100:  result = a ^ b;       // xor
    3'b101:  result = a < b;       // slt
    3'b110:  result = a << b;       // sll
    3'b111:  result = a >> b;       // srl
    default: result = 32'bx;
    endcase
    
    assign zero = (result == 32'b0);
    assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
    
endmodule
    
