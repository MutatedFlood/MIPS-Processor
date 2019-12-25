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

    reg [31:2] PC;
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

    reg type_R;
    reg equal_out;
    reg unequal_out;

    integer tempvar;

    assign IR_addr = PC;
    assign A = add_out[8:2];
    assign Data2Mem = data_Rt;
    assign CEN = OEN && WEN;
    assign OEN = reg_OEN;
    assign WEN = reg_WEN;

    wire flag_jr = (funct == 6'h08);
    reg flag_j;
    reg flag_jal;
    reg flag_beq;
    reg flag_bne;
    reg flag_addi;
    reg flag_lw;
    reg flag_sw;

    always @* begin
        type_R = 0;
        flag_j = 0;
        flag_jal = 0;
        flag_beq = 0;
        flag_bne = 0;
        flag_addi = 0;
        flag_lw = 0;
        flag_sw = 0;
        case (op_code)
            6'h00: type_R = 1;
            6'h02: flag_j = 1;
            6'h03: flag_jal = 1;
            6'h04: flag_beq = 1;
            6'h05: flag_bne = 1;
            6'h08: flag_addi = 1;
            6'h23: flag_lw = 1;
            6'h2b: flag_sw = 1;
        endcase
    end

    always @* begin
        if (sub_out) begin
            equal_out = 0;
            unequal_out = 1;
        end
        else begin
            equal_out = 1;
            unequal_out = 0;
        end
    end

    always @* begin
        if (type_R) candidate_add = data_Rt;
        else candidate_add = ext_I_addr;
    end

    always @* begin
        if (type_R && flag_jr) net_PC = data_Rs;
        else if (flag_j || flag_jal) net_PC = jump_addr;
        else if (flag_beq && equal_out) net_PC = branch_addr;
        else if (flag_bne && unequal_out) net_PC = branch_addr;
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
        if (flag_addi) to_Rt = add_out;
        else if (flag_lw) to_Rt = ReadDataMem;
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
        if (flag_jal) R31 = PC_4;
        else R31 = registers[31];
    end

    always @* begin
        if (flag_lw) reg_OEN = 0;
        else reg_OEN = 1;
    end

    always @* begin
        if (flag_sw) reg_WEN = 0;
        else reg_WEN = 1;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            registers[Rd] <= to_Rd;
            registers[Rt] <= to_Rt;
            registers[31] <= R31;
        end
        else begin
            for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1) begin
                registers[tempvar] <= 32'd0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n) begin
            PC <= net_PC;
            prev_Rt <= Rt;
            prev_Rd <= Rd;
            prev_to_Rt <= to_Rt;
            prev_to_Rd <= to_Rd;
        end
        else begin
            PC <= {32{1'b0}};
            prev_Rt <= 0;
            prev_Rd <= 0;
            prev_to_Rt <= 0;
            prev_to_Rd <= 0;
        end
    end
endmodule
