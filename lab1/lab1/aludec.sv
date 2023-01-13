module aludec(input logic [1:0] ALUOp, input logic [2:0] funct3, input logic opb5, 
		input logic funct7b5, output logic [2:0] ALUControl);
logic n1, n2, n3;
// The following logic gates are part of SystemVerilog Spec
// (built-in primitives). // The first signal (e.g., ns) is the output. The rest(e.g., a, b) are
// inputs. // sum logic
// carry logic
and a1(ALUControl[2], ALUOp[1], ~funct3[2], funct3[1], ~funct3[0]); // n1 = a & b
and a2(ALUControl[1], ALUOp[1], funct3[2], funct3[1]); // n2 = a & cin
and a3(n1, ~ALUOp[1], ALUOp[0]); // n3 = b & cin
and a4(n2, ALUOp[1], funct3[1], ~funct3[0]);
and a5(n3, ALUOp[1], ~funct3[1], opb5, funct7b5);
or o1(ALUControl[0], n1, n2, n3); // n4 = n1 | n2

endmodule

// Declare 5 internal logic signals or local variables
// which can only be used inside of this module
