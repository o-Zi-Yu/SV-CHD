module testbench_aludec();
logic clk, reset;
// 'clk' & 'reset' are common names for the clock and the reset, // but they're not reserved. 
logic [1:0] ALUOp;
logic [2:0] funct3;
logic opb5, funct7b5;
logic [2:0] ALUControl;
logic [2:0] ALUControlexpected;
// These variables or signals represent 3 inputs, 2 outputs, 2 expected
// outputs, respectively. 
logic [31:0] vectornum, errors;
logic [4:0] testvectors[10000:0];

aludec dut(ALUOp, funct3, opb5, funct7b5, ALUControl);
always
// 'always' statement causes the statements in the block to be
// continuously re-evaluated. 
    begin
    // Create clock with period of 10 time units. 
    // Set the clk signal HIGH(1) for 5 units, LOW(0) for 5 units
    clk=1; #5;
    clk=0; #5;
    end

//// Start of test. 
initial
// 'initial' is used only in testbench simulation. 
    begin
        // Load vectors stored as 0s and 1s (binary) in .tv file. 
        $readmemb("testbench_aludec.tv", testvectors);
        // $readmemb reads binarys, $readmemh reads hexadecimals. // Initialize the number of vectors applied & the amount of
        // errors detected. 
        vectornum=0;
        errors=0;
        // Both signals hold 0 at the beginning of the test. //// Pulse reset for 22 time units(2.2 cycles) so the reset
        // signal falls after a clk edge. 
        reset=1; #22;
        reset=0;
        // The signal starts HIGH(1) for 22 time units then remains LOW(0)
        // for the rest of the test. 
    end

always @(posedge clk)

    begin
        #1;
        {ALUOp, funct3, opb5, funct7b5, ALUControl, ALUControlexpected} = testvectors[vectornum];
    end

always @(negedge clk)
    if (~reset) begin
    //// Detect error by checking if outputs from DUT match
    // expectation. 
        if (ALUControl !== ALUControlexpected) begin
    // If error is detected, print all 3 inputs, 2 outputs, // 2 expected outputs. 
            $display("Error: inputs = %b", {ALUOp, funct3, opb5, funct7b5});
    // '$display' prints any statement inside the quotation to
    // the simulator window. // %b, %d, and %h indicate values in binary, decimal, and
    // hexadecimal, respectively. // {a, b, cin} create a vector containing three signals. 
            $display(" outputs = %b ( %b expected)", ALUControl, ALUControlexpected);
    //// Increment the count of errors. 
            errors = errors + 1;
    end
    //// In any event, increment the count of vectors. 
    vectornum = vectornum + 1;
    //// When the test vector becomes all 'x', that means all the
    // vectors that were initially loaded have been processed, thus
    // the test is complete. 
    if (testvectors[vectornum] === 5'bx) begin
    // '==='&'!==' can compare unknown & floating values (X&Z),unlike
    // '=='&'!=', which can only compare 0s and 1s. // 5'bx is 5-bit binary of x's or xxxxx. // If the current testvector is xxxxx, report the number of
    // vectors applied & errors detected. 
        $display("%d tests completed with %d errors", vectornum, errors);
    // Then stop the simulation. 
        $stop;
    end
end

endmodule