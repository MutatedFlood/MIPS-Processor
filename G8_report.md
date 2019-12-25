# MIPS Processor
Group 8
B05901033 電機四 莊永松
B06901038 電機三 王人出

## A. Snapshot
### 1. Readme.txt content
```
cycle time: 8.1
FPU Single: Y
FPU Double: Y
```
### 2. All RTL Simulation you pass
- CPU RTL
![](https://i.imgur.com/XXivLQB.png)
- FPU RTL
    - 跑 Baseline
    ![](https://i.imgur.com/EruQzZj.png)
    - 跑 Single
    ![](https://i.imgur.com/DWlQO47.png)
    - 跑 Double
    ![](https://i.imgur.com/wfXWk5O.png)



### 3. All Gate-level Simulation you pass


- CPU Gate-level (cycle=8.07, total time 6222.6 NS)
    ![](https://i.imgur.com/J0QqrR9.png)
- FPU Gate-level
    - 跑 Baseline (cycle=70)
    ![](https://i.imgur.com/pgSNKIA.png)
    - 跑 Single (cycle=70)
    ![](https://i.imgur.com/qykUfOP.png)
    - 跑 double (cycle=70)
    ![](https://i.imgur.com/oy7ohhq.png)




### 4. Timing report
- CPU
    - Cycle: 8.07
    - Slack: 0.01 (用8.0去合成)
    ![](https://i.imgur.com/69dCDiz.png)


- FPU 
    - Cycle: 70
    - Slack: 0.00
    ![](https://i.imgur.com/5xmbQNd.png)

### 5. Area report
- CPU Area: 87750
![](https://i.imgur.com/rbaklWD.png)


- FPU Area: 404960
![](https://i.imgur.com/Dak1ITq.png)


## B. Your baseline A\*T value calculated from numbers in the snapshot
A\*T(cycle) = 87750 * 8.07 = 708142.5
A\*T(total time) = 87750 * 6222.6(NS) = 546033150


## C. Please describe how you design this circuit and what difficulties you encountered when working on this exercise.

- 我們發現助教把jal寫成用PC+4了，但其實應該是PC+8，原本乖乖寫PC+8會過不了testbench，推測是助教用RISC-V的code來改，以致於沒改到
- 沒發現 pipeline register initialize 的重要性，如果沒有 initialize 在RTL的時候沒有問題，但合成完就會害某些register變成xxxxx
- 沒發現 Rt = Rd 的時候要有優先次序（Rd先）
- 沒發現 memory 的 index 單位是 word 而非 byte
- 沒發現 FPU 在測 Baseline 的時候不需要加 `+FPU`，結果 load 到 fp 的 memory




## D. Work distribution
王人出：負責 design 整個 CPU 架構，也幫 FPU debug
莊永松：負責 design 整個 FPU 架構，也幫 CPU debug
兩位助教：幫我們的 CPU/FPU 找出重要的 bug😍

## E. (optional) how you improve your A\*T value.
- 加上簡易的 skip connection(有點像pipeline)，用forwarding的方法，其latency會比寫入register再讀出來的方法低。也因此我們的cycle time可以壓到8.07，相當低😍😍。
- 使用 MUX 重複利用加減運算 unit，以減少 ALU sub-units 的數量
