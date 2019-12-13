module SingleCycleMIPS_FPU( 
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

    input         clk, rst_n;
    input  [31:0] IR;
    output [31:0] IR_addr;

    input  [31:0] ReadDataMem;  
    output        CEN;  
    output        WEN;  
    output  [6:0] A;  
    output [31:0] Data2Mem;  
    output        OEN;  

    always @* begin

    end

    always @(posedge clk) begin
        if (rst_n) begin
            
        end
        else begin
            
        end
    end

endmodule
