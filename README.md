# MIPS-Processor

A rather nice (~I suppose~ _proven_) single-cycle MIPS processor implementation in verilog.

![MIPS](https://i.imgur.com/0rWtHU7.png)

Authors: [Ren-Chu Wang](https://github.com/w4n9r3ntru3), [Yung-Sung Chuang](https://github.com/voidism)

## Specifications

### Input/Output
![](https://i.imgur.com/OD8Kznw.png)

### CPU operations
![](https://i.imgur.com/4Qqojnm.png)

### FPU operations
![](https://i.imgur.com/nIRsoMS.png)

## Simulation Scripts
### I. Environmental Settings
Source the ./cshrc file
```
source ./cshrc
```

### II. RTL Simulation
```
ncverilog tb.v SingleCycleMIPS.v +define+Baseline +access+r
```
### III. Synthesis
```
dc_shell -f run.tcl
```

### IV. Gate-level Simulation
```
ncverilog tb.v SingleCycleMIPS_syn.v tsmc13.v +define+Baseline+SDF +access+r
```

### V. RTL Simulation for FPU
```
ncverilog tb.v SingleCycleMIPS_FPU.v +define+Baseline +access+r

ncverilog tb.v SingleCycleMIPS_FPU.v +define+FPU+Single +access+r

ncverilog tb.v SingleCycleMIPS_FPU.v +define+FPU+Double +access+r
```


### VI. Gate-level Simulation for FPU
```
ncverilog tb.v SingleCycleMIPS_FPU_syn.v tsmc13.v +define+FPU+Single +access+r
```

### VII. Debug
```
ncverilog tb.v SingleCycleMIPS_FPU_syn.v tsmc13.v +define+FPU+Double +access+r
```
