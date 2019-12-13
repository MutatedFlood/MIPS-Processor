`define DEBUG
`define LW_SW_SEPARATED // no consecutive lw sw
`define IFELSE(IFCLAUSE, IFTRUE, IFFALSE) ((IFCLAUSE) ? (IFTRUE) : (IFFALSE))

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
    input clk, rst_n;
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

    wire [31:0] ext_I_addr = {{16{I_addr[15]}}, I_addr};

    wire jump = (op_code == 6'h02 || op_code == 6'h03);
    wire jump_reg = (op_code == 6'h00 && funct == 6'h08);
    wire branch_eq = (op_code == 6'h04);
    wire branch_ne = (op_code == 6'h05);

    wire [31:0] PC_4 = {PC[29:0], 2'b0};
    wire [31:0] jump_to = {PC[31:28], J_addr, 2'b0};
    wire [31:0] branch_to = PC_4 + {ext_I_addr[29:0], 2'b0};
    reg [31:0] PC_net;

    wire [31:0] Rs_dat = registers[Rs];
    wire [31:0] Rt_dat = registers[Rt];
    reg [31:0] Rd_dat;

    reg [31:0] add_candidate;

    wire [31:0] sll_out = Rt_dat << shamt;
    wire [31:0] srl_out = Rt_dat >> shamt;
    wire [31:0] add_out = Rs_dat + add_candidate;
    wire [31:0] sub_out = Rs_dat - Rt_dat;
    wire [31:0] and_out = Rs_dat & Rt_dat;
    wire [31:0] or_out = Rs_dat | Rt_dat;
    wire slt_out = sub_out[31];

    always @* begin
        if (op_code == 6'h00) add_candidate = Rt_dat;
        else add_candidate = ext_I_addr;
    end

    integer tempvar;

    always @* begin
        if (jump) begin
            PC_net = jump_to;
        end
        else if (jump_reg) begin
            PC_net = Rs_dat;
        end
        else if (branch_eq) begin
            if (~|sub_out) PC_net = branch_to;
            else PC_net = PC_4;
        end
        else if (branch_ne) begin
            if (~|sub_out) PC_net = PC_4;
            else PC_net = branch_to;
        end
        else begin
            PC_net = PC_4;
        end
    end

    assign IR_addr = PC;
    assign CEN = OEN & WEN;

    always @(posedge clk) begin
        if (rst_n) begin
            PC <= PC_net;
        end
        else begin
            PC <= 0;
            for (tempvar = 0; tempvar < 32; tempvar = tempvar + 1) begin
                registers[tempvar] <= 'b0;
            end
        end
    end

endmodule
