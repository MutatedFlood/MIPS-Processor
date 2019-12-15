`include "./SingleCycleMIPS.v"

module testIR;

	reg clk;
	reg rst_n;
	wire [31:0] IR_addr;
	reg [31:0] IR;
	reg [31:0] RDM;
	wire CEN;
	wire WEN;
	wire [6:0] A;
	wire [31:0] Data2Mem;
	wire OEN;

    reg [5:0] OpCode; // all
    reg [4:0] Rs; // R, I
    reg [4:0] Rt; // R, I
    reg [4:0] Rd; // R
    reg [4:0] shamt; // R
    reg [5:0] funct; // R
    reg [15:0] IAddr; // I
	reg [31:0] ExtIAddr; // I
    reg [25:0] JAddr; // J

	SingleCycleMIPS scmips(
		clk,
		rst_n,
		IR_addr,
		IR,
		RDM,
		CEN,
		WEN,
		A,
		Data2Mem,
		OEN
	);

    integer tempvar;

    always #5 clk = !clk;

    initial begin
        $dumpfile("IR.vcd");
        $dumpvars;
    end

    initial begin
        clk = 0;
        rst_n = 0;
        rst_n = #11 1;
    end

    always @(posedge clk) begin
        $display("time=%d", $time);
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1) begin
            if (tempvar % 8 == 0) begin
                $display;
            end
            $write("%d ", scmips.registers[tempvar]);
        end
        $display; $display;
    end

    initial begin
        RDM = 19;

        #20;
        $display("addi");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h08;
        Rs = 3;
        Rt = 4;
        IAddr = 10;
        IR = {OpCode, Rs, Rt, IAddr};
        #10;
        #10;

        $display("beq");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h04;
        Rs = 3;
        Rt = 4;
        IAddr = 10;
        IR = {OpCode, Rs, Rt, IAddr};
        #10;
        #10;

        $display("bne");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h05;
        Rs = 3;
        Rt = 4;
        IAddr = 10;
        IR = {OpCode, Rs, Rt, IAddr};
        #10;
        #10;

        $display("j, address = %d", IR_addr);
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h02;
        JAddr = 64;
        IR = {OpCode, JAddr};
        #10;
        $display("new address = %d", IR_addr);
        #10;

        $display("jal, address = %d", IR_addr);
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h03;
        JAddr = 128;
        IR = {OpCode, JAddr};
        #10;
        $display("new address = %d", IR_addr);
        #10;

        $display("sll");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h00;
        funct = 6'h00;
        shamt = 1;
        Rs = 5;
        Rt = 6;
        Rd = 7;
        IR = {OpCode, Rs, Rt, Rd, shamt, funct};
        #10;
        #10;

        $display("srl");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h00;
        funct = 6'h02;
        shamt = 1;
        Rs = 5;
        Rt = 6;
        Rd = 7;
        IR = {OpCode, Rs, Rt, Rd, shamt, funct};
        #10;
        #10;

        $display("add");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h00;
        funct = 6'h20;
        shamt = 1;
        Rs = 5;
        Rt = 6;
        Rd = 7;
        IR = {OpCode, Rs, Rt, Rd, shamt, funct};
        #10;
        #10;

        $display("sub");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h00;
        funct = 6'h22;
        shamt = 1;
        Rs = 5;
        Rt = 6;
        Rd = 7;
        IR = {OpCode, Rs, Rt, Rd, shamt, funct};
        #10;
        #10;

        $display("and");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h00;
        funct = 6'h24;
        shamt = 1;
        Rs = 5;
        Rt = 6;
        Rd = 7;
        IR = {OpCode, Rs, Rt, Rd, shamt, funct};
        #10;
        #10;

        $display("or");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h00;
        funct = 6'h25;
        shamt = 1;
        Rs = 5;
        Rt = 6;
        Rd = 7;
        IR = {OpCode, Rs, Rt, Rd, shamt, funct};
        #10;
        #10;

        $display("slt");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h00;
        funct = 6'h2a;
        shamt = 1;
        Rs = 5;
        Rt = 6;
        Rd = 7;
        IR = {OpCode, Rs, Rt, Rd, shamt, funct};
        #10;
        #10;

        $display("jr");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h00;
        funct = 6'h08;
        shamt = 1;
        Rs = 5;
        Rt = 6;
        Rd = 7;
        IR = {OpCode, Rs, Rt, Rd, shamt, funct};
        #10;
        $display("new address = %d", IR_addr);
        #10;

        $display("lw, data = %d", RDM);
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h23;
        Rs = 3;
        Rt = 4;
        IAddr = 10;
        IR = {OpCode, Rs, Rt, IAddr};
        #10;
        #10;

        $display("sw");
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1)
            scmips.registers[tempvar] = tempvar;
        OpCode = 6'h2b;
        Rs = 3;
        Rt = 4;
        IAddr = 10;
        IR = {OpCode, Rs, Rt, IAddr};
        #10;
        #10;
        $display("to save = %d", Data2Mem);

        $finish;
    end

endmodule
