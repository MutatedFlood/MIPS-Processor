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
    reg [31:0] registers_FF [0:31];

    reg double_stall;
    reg double_stall_prev;

    wire [5:0] op_code = IR[31:26];
    wire [4:0] Rs = IR[25:21];
    wire [4:0] Rt = (double_stall_prev)?IR[20:16]+1:IR[20:16];
    wire [4:0] Rd = IR[15:11];
    wire [4:0] shamt = IR[10:6];
    wire [5:0] funct = IR[5:0];
    wire [15:0] I_addr = IR[15:0];
    wire [25:0] J_addr = IR[25:0];

    reg [31:2] net_PC;
    wire [31:2] PC_4 = PC + 1;
    wire [31:0] ext_I_addr = {{16{I_addr[15]}}, I_addr};
    wire [31:2] jump_addr = {PC_4[31:28], J_addr};
    wire [31:2] branch_addr = PC_4 + ext_I_addr[29:0];

    reg [31:0] data_Rs;
    reg [31:0] data_Rt;
    reg [31:0] candidate_add;
    reg [31:0] R31;
    reg [31:0] to_Rt;
    reg [31:0] to_Rd;

    wire [31:0] sll_out = data_Rt << shamt;
    wire [31:0] srl_out = data_Rt >> shamt;
    wire [31:0] add_out = data_Rs + candidate_add;
    wire [31:0] sub_out = data_Rs - data_Rt;
    wire [31:0] and_out = data_Rs & data_Rt;
    wire [31:0] or_out = data_Rs | data_Rt;
    wire [31:0] slt_out = {31'd0, sub_out[31]};

    // FPU part
    reg [31:0] FP_registers [0:31];
    reg [31:0] FP_registers_FF [0:31];
    reg [31:0] data_Fs;
    reg [31:0] data_Ft;
    reg [63:0] FP64_data_Fs;
    reg [63:0] FP64_data_Ft;
    reg [31:0] FP_data_Rt;
    reg [31:0] FP_to_Rt;
    reg [31:0] to_Fd;
    reg [31:0] to_Fd_1;
    wire [4:0] fmt = IR[25:21];
    wire [4:0] Ft = IR[20:16];
    wire [4:0] Fs = IR[15:11];
    wire [4:0] Fd = IR[10:6];

    reg [2:0] rounding_mode;
    // FPU Adder
    wire [31:0] fp32_add_out;
    wire [7:0] fp32_add_status;
    DW_fp_add #(.sig_width(23),.exp_width(8),.ieee_compliance(0)) 
    FP32_adder (.a(data_Fs), .b(data_Ft), .rnd(rounding_mode),
                .z(fp32_add_out), .status(fp32_add_status));
    // FPU Suber
    wire [31:0] fp32_sub_out;
    wire [7:0] fp32_sub_status;
    DW_fp_sub #(.sig_width(23),.exp_width(8),.ieee_compliance(0)) 
    FP32_suber (.a(data_Fs), .b(data_Ft), .rnd(rounding_mode),
                .z(fp32_sub_out), .status(fp32_sub_status));
    // FPU Multiplier
    wire [31:0] fp32_mult_out;
    wire [7:0] fp32_mult_status;
    DW_fp_mult #(.sig_width(23),.exp_width(8),.ieee_compliance(0)) 
    FP32_multer (.a(data_Fs), .b(data_Ft), .rnd(rounding_mode),
                 .z(fp32_mult_out), .status(fp32_mult_status));
    // FPU Divider
    wire [31:0] fp32_div_out;
    wire [7:0] fp32_div_status;
    DW_fp_div #(.sig_width(23),.exp_width(8),.ieee_compliance(0)) 
    FP32_diver (.a(data_Fs), .b(data_Ft), .rnd(rounding_mode),
                .z(fp32_div_out), .status(fp32_div_status));
    // FPU Comparator
    wire [31:0] fp32_cmp_out;
    wire [31:0] fp32_z0;
    wire [31:0] fp32_z1;
    wire [7:0] fp32_cmp_status0;
    wire [7:0] fp32_cmp_status1;
    reg fp32_zctr;
    wire fp32_aeqb;
    wire fp32_altb;
    wire fp32_agtb;
    wire fp32_unordered;
    DW_fp_cmp #(.sig_width(23),.exp_width(8),.ieee_compliance(0)) 
    FP32_cmper (.a(data_Fs), .b(data_Ft), .zctr(fp32_zctr), .aeqb(fp32_aeqb),
                .altb(fp32_altb), .agtb(fp32_agtb), .unordered(fp32_unordered),
                .z0(fp32_z0), .z1(fp32_z1), .status0(fp32_cmp_status0), .status1(fp32_cmp_status1));
    // module DW_fp_cmp (a, b, zctr, aeqb, altb, agtb, unordered, z0, z1, status0, status1);


    // FPU Double part
    // FPU Double Adder
    wire [63:0] fp64_add_out;
    wire [7:0] fp64_add_status;
    DW_fp_add #(.sig_width(52),.exp_width(11),.ieee_compliance(0)) 
    FP64_adder (.a(FP64_data_Fs), .b(FP64_data_Ft), .rnd(rounding_mode),
                .z(fp64_add_out), .status(fp64_add_status));
    // FPU Double Suber
    wire [63:0] fp64_sub_out;
    wire [7:0] fp64_sub_status;
    DW_fp_sub #(.sig_width(52),.exp_width(11),.ieee_compliance(0)) 
    FP64_suber (.a(FP64_data_Fs), .b(FP64_data_Ft), .rnd(rounding_mode),
                .z(fp64_sub_out), .status(fp64_sub_status));
    
    reg type_FR;
    reg FPcond;
    reg net_FPcond;

    reg reg_OEN;
    reg reg_WEN;

    reg type_R;
    reg equal_out;
    reg unequal_out;

    integer tempvar;

    assign IR_addr = {PC, 2'd0};
    assign A = add_out[8:2];
    reg [31:0] Data2Mem_reg; 
    assign Data2Mem = Data2Mem_reg;
    assign CEN = OEN && WEN;
    assign OEN = reg_OEN;
    assign WEN = reg_WEN;

    wire flag_jr = (funct == 6'h08);
    reg flag_j;
    reg flag_jal;
    reg flag_beq;
    reg flag_bne;
    reg flag_addi;
    reg flag_lwc1;
    reg flag_ldc1;
    reg flag_lw;
    reg flag_swc1;
    reg flag_sdc1;
    reg flag_sw;
    reg flag_bc1t;
    reg flag_bc1f;

    always @* begin
        type_R = 0;
        type_FR = 0;
        flag_j = 0;
        flag_jal = 0;
        flag_beq = 0;
        flag_bne = 0;
        flag_addi = 0;
        flag_lwc1 = 0;
        flag_ldc1 = 0;
        flag_lw = 0;
        flag_swc1 = 0;
        flag_sdc1 = 0;
        flag_sw = 0;
        case (op_code)
            6'h00: type_R = 1;
            6'h02: flag_j = 1;
            6'h03: flag_jal = 1;
            6'h04: flag_beq = 1;
            6'h05: flag_bne = 1;
            6'h08: flag_addi = 1;
            6'h11: type_FR = 1;
            6'h23: flag_lw = 1;
            6'h2b: flag_sw = 1;
            6'h31: flag_lwc1 = 1;
            6'h35: flag_ldc1 = 1;
            6'h39: flag_swc1 = 1;
            6'h3d: flag_sdc1 = 1;
        endcase
    end

    always @* begin
        flag_bc1f = 0;
        flag_bc1t = 0;
        if (type_FR && fmt == 6'h08) begin
            case (Ft)
                6'h00: flag_bc1f = 1;
                6'h01: flag_bc1t = 1;
            endcase
        end
    end

    always @* begin
        net_FPcond = FPcond;
        if (type_FR) begin
            case (fmt)
                6'h10: net_FPcond = fp32_aeqb;
            endcase
        end
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
        if (double_stall_prev) double_stall = 0;
        else if (flag_sdc1 || flag_ldc1) double_stall = 1;
        else double_stall = 0;
    end

    always @* begin
        if (type_R) candidate_add = data_Rt;
        else if (double_stall_prev) candidate_add = ext_I_addr + 4;
        else candidate_add = ext_I_addr;
    end

    reg fpu_control;

    always @* begin
        if (type_R && flag_jr) net_PC = data_Rs;
        else if (flag_j || flag_jal) net_PC = jump_addr;
        else if (flag_beq && equal_out) net_PC = branch_addr;
        else if (flag_bne && unequal_out) net_PC = branch_addr;
        else if (flag_bc1t && FPcond) net_PC = branch_addr;
        else if (flag_bc1f && !FPcond) net_PC = branch_addr;
        else if (flag_ldc1 && !double_stall_prev) net_PC = PC;
        else if (flag_sdc1 && !double_stall_prev) net_PC = PC;
        else net_PC = PC_4;
    end
    
    always @* begin
        data_Rs = registers_FF[Rs];
        data_Rt = registers_FF[Rt];
    end
    
    always @* begin
        data_Fs = FP_registers_FF[Fs];
        FP_data_Rt = FP_registers_FF[Rt];
        data_Ft = FP_registers_FF[Ft];
        FP64_data_Fs = {FP_registers_FF[Fs], FP_registers_FF[Fs+1]};
        FP64_data_Ft = {FP_registers_FF[Ft], FP_registers_FF[Ft+1]};
    end

    always @* begin
        if (flag_addi) to_Rt = add_out;
        else if (flag_lw) to_Rt = ReadDataMem;
        else to_Rt = data_Rt;
    end

    always @* begin
        if (flag_lwc1 || flag_ldc1) FP_to_Rt = ReadDataMem;
        else FP_to_Rt = FP_data_Rt;
    end

    always @* begin
        if (flag_swc1 || flag_sdc1) Data2Mem_reg = FP_data_Rt;
        else Data2Mem_reg = data_Rt;
    end

    always @* begin
        to_Rd = registers_FF[Rd];
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
        to_Fd = FP_registers_FF[Fd];
        to_Fd_1 = FP_registers_FF[Fd+1];
        if (type_FR) begin
            if (fmt == 6'h10) begin
                case (funct)
                    6'h00: to_Fd = fp32_add_out;
                    6'h01: to_Fd = fp32_sub_out;
                    6'h02: to_Fd = fp32_mult_out;
                    6'h03: to_Fd = fp32_div_out;
                endcase
            end
            if (fmt == 6'h11) begin
                case (funct)
                    6'h00: begin 
                        to_Fd = fp64_add_out[63:32]; 
                        to_Fd_1 = fp64_add_out[31:0]; 
                    end
                    6'h01: begin 
                        to_Fd = fp64_sub_out[63:32]; 
                        to_Fd_1 = fp64_sub_out[31:0]; 
                    end
                endcase
            end
        end
    end

    always @* begin
        if (flag_jal) R31 = PC_4;
        else R31 = registers_FF[31];
    end

    always @* begin
        if (flag_lw || flag_lwc1 || flag_ldc1) reg_OEN = 0;
        else reg_OEN = 1;
    end

    always @* begin
        if (flag_sw || flag_swc1 || flag_sdc1) reg_WEN = 0;
        else reg_WEN = 1;
    end

    always @* begin
        for (tempvar = 0; tempvar < 31; tempvar = tempvar + 1) begin
            registers[tempvar] = registers_FF[tempvar];
        end
        registers[Rt] = to_Rt;
        registers[Rd] = to_Rd;
        registers[31] = R31;
    end

    always @* begin
        for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1) begin
            FP_registers[tempvar] = FP_registers_FF[tempvar];
        end
        FP_registers[Rt] = FP_to_Rt;
        FP_registers[Fd] = to_Fd;
        FP_registers[Fd+1] = to_Fd_1;
    end

    always @(posedge clk) begin
        rounding_mode <= 3'b0;
        fp32_zctr <= 0;
        double_stall_prev <= double_stall;
    end

    always @(posedge clk) begin
        registers_FF[0] <= 32'd0;
        if (rst_n) begin
            for (tempvar = 1; tempvar < 32; tempvar = tempvar + 1) begin
                registers_FF[tempvar] <= registers[tempvar];
            end
        end
        else begin
            for (tempvar = 1; tempvar < 32; tempvar = tempvar + 1) begin
                registers_FF[tempvar] <= 32'd0;
            end
        end
    end

    always @(posedge clk) begin
        // FP_registers_FF[0] <= 32'd0;
        if (rst_n) begin
            for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1) begin
                FP_registers_FF[tempvar] <= FP_registers[tempvar];
            end
        end
        else begin
            for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1) begin
                FP_registers_FF[tempvar] <= 32'd0;
            end
        end
    end

    always @(posedge clk) begin
        if (rst_n) PC <= net_PC;
        else PC <= 32'd0;
    end

    always @(posedge clk) begin
        if (rst_n) FPcond <= net_FPcond;
        else FPcond <= 1'b0;
    end
endmodule