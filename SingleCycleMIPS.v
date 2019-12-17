module SingleCycleMIPS( 
    clk,
    rst_n,
    IR_addr,
    IR,
    ReadDataMem,
    CEN,
    WEN,
    A,
    Data2Mem,
    OEN
);
    input clk;
    input rst_n;
    input  [31:0] IR;
    output [31:0] IR_addr;

    input  [31:0] ReadDataMem;  
    output CEN;  
    output WEN;  
    output [6:0] A;  
    output [31:0] Data2Mem;  
    output OEN;

    reg [31:0] PC;
    reg [31:0] registers [0:31];

    wire [5:0] op_code = IR[31:26];
    wire [4:0] Rs = IR[25:21];
    wire [4:0] Rt = IR[20:16];
    wire [4:0] Rd = IR[15:11];
    wire [4:0] shamt = IR[10:6];
    wire [5:0] funct = IR[5:0];
    wire [15:0] I_addr = IR[15:0];
    wire [25:0] J_addr = IR[25:0];

    reg [31:0] net_PC;
    wire [31:0] PC_4 = PC + 4;
    wire [31:0] ext_I_addr = {{16{I_addr[15]}}, I_addr};
    wire [31:0] shift_ext_I_addr = {ext_I_addr[29:0], 2'd0};
    wire [31:0] jump_addr = {PC_4[31:28], J_addr, 2'd0};
    wire [31:0] branch_addr = PC_4 + shift_ext_I_addr;

    reg [31:0] data_Rs;
    reg [31:0] data_Rt;
    reg [31:0] to_Rd;
    reg [31:0] to_Rt;
    reg [31:0] prev_to_Rd;
    reg [31:0] prev_to_Rt;
    reg [31:0] candidate_add;
    reg [31:0] R31;
    reg [31:0] prev_R31;
    reg [4:0] prev_Rt;
    reg [4:0] prev_Rd;

    wire [31:0] sll_out = data_Rt << shamt;
    wire [31:0] srl_out = data_Rt >> shamt;
    wire [31:0] add_out = data_Rs + candidate_add;
    wire [31:0] sub_out = data_Rs - data_Rt;
    wire [31:0] and_out = data_Rs & data_Rt;
    wire [31:0] or_out = data_Rs | data_Rt;
    wire [31:0] slt_out = {{31{1'b0}}, sub_out[31]};

    reg reg_OEN;
    reg reg_WEN;

    wire type_R = (op_code == 6'h00);
    wire unequal_out = (data_Rs != data_Rt);

    integer tempvar;

    assign IR_addr = PC;
    assign A = add_out[8:2];
    assign Data2Mem = data_Rt;
    assign CEN = OEN && WEN;
    assign OEN = reg_OEN;
    assign WEN = reg_WEN;

    always @* begin
        if (type_R) candidate_add = data_Rt;
        else candidate_add = ext_I_addr;
    end

    always @* begin
        if (type_R && funct == 6'h08) net_PC = data_Rs;
        else if (op_code == 6'h02 || op_code == 6'h03) net_PC = jump_addr;
        else if (op_code == 6'h04 && !unequal_out) net_PC = branch_addr;
        else if (op_code == 6'h05 && unequal_out) net_PC = branch_addr;
        else net_PC = PC_4;
    end

    always @* begin
        if (Rs == prev_Rd) data_Rs = prev_to_Rd;
        else if (Rs == prev_Rt) data_Rs = prev_to_Rt;
        else data_Rs = registers[Rs];
    end

    always @* begin
        if (Rt == prev_Rd) data_Rt = prev_to_Rd;
        else if (Rt == prev_Rt) data_Rt = prev_to_Rt;
        else data_Rt = registers[Rt];
    end

    always @* begin
        if (op_code == 6'h08) to_Rt = add_out;
        else if (op_code == 6'h23) to_Rt = ReadDataMem;
        else to_Rt = data_Rt;
    end

    always @* begin
        to_Rd = registers[Rd];
        if (type_R) begin
            case (funct)
                6'h00: to_Rd = sll_out;
                6'h02: to_Rd = srl_out;
                6'h20: to_Rd = add_out;
                6'h22: to_Rd = sub_out;
                6'h24: to_Rd = and_out;
                6'h25: to_Rd = or_out;
                6'h2a: to_Rd = slt_out;
            endcase
        end
    end

    always @* begin
        if (op_code == 6'h03) R31 = PC_4;
        else R31 = registers[31];
    end

    always @* begin
        if (op_code == 6'h23) reg_OEN = 0;
        else reg_OEN = 1;
    end

    always @* begin
        if (op_code == 6'h2b) reg_WEN = 0;
        else reg_WEN = 1;
    end

    always @(negedge clk) begin
        if (rst_n) begin
            registers[prev_Rd] <= prev_to_Rd;
            registers[prev_Rt] <= prev_to_Rt;
            registers[31] <= prev_R31;
        end
        else begin
            for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1) begin
                registers[tempvar] <= {32{1'b0}};
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n) begin
            PC <= net_PC;
            prev_Rt <= Rt;
            prev_Rd <= Rd;
            prev_to_Rd <= to_Rd;
            prev_to_Rt <= to_Rt;
            prev_R31 <= R31;
        end
        else begin
            PC <= {32{1'b0}};
        end
    end
endmodule
