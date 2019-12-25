# MIPS Processor

## A. Snapshot
### 1. Readme.txt content (see sec. 8)
```
cycle time: 8.1
FPU Single: Y
FPU Double: Y
```
### 2. All RTL Simulation you pass (see Appendix II for example)
- Baseline RTL
![](https://i.imgur.com/XXivLQB.png)
- FPU RTL
    - 跑 Baseline
    ![](https://i.imgur.com/EruQzZj.png)
    - 跑 Single
    ![](https://i.imgur.com/DWlQO47.png)
    - 跑 Double
    ![](https://i.imgur.com/wfXWk5O.png)



### 3. All Gate-level Simulation you pass


- Baseline Gate-level
    ![](https://i.imgur.com/DllgFao.png)
- FPU Gate-level
    - 跑 Baseline
    - 跑 Single
    ![](https://i.imgur.com/m152vaF.png)
    - 跑 double
    ![](https://i.imgur.com/LqWysRd.png)



### 4. Timing report
- Baseline 
    - Cycle: 8.1
    - Slack: 0.01
    ![](https://i.imgur.com/69dCDiz.png)


- FPU 
    - Cycle: 
    - Slack:
### 5. Area report
- Baseline Area: 87750
![](https://i.imgur.com/rbaklWD.png)


- FPU Area: 333858
![](https://i.imgur.com/jWP46RO.png)

## B. Your baseline A\*T value calculated from numbers in the snapshot
A\*T = 87750 * 8.1 = 710775

## C. Please describe how you design this circuit and what difficulties you encountered when working on this exercise.

- 我們發現助教把jal寫成用PC+4了，但其實應該是PC+8，原本乖乖寫PC+8會過不了testbench，推測是助教RISC-V寫太多，以致於沒改到
- 沒發現 pipeline register initialize 的重要性，如果沒有 initialize 在RTL的時候沒有問題，但合成完就會害某些register變成xxxxx
- 沒發現 Rt = Rd 的時候要有優先次序（Rd先）
- 沒發現 memory 的 index 單位是 word 而非 byte




## D. Work distribution
王人出：負責design整個CPU架構，也幫FPU debug
莊永松：負責design整個FPU架構，也幫CPU debug

## E. (optional) how you improve your A\*T value.
- 加上簡易的兩階Pipeline，用forwarding的方法，其latency會比寫入register再讀出來的方法低。也因此我們的cycle time可以壓到8.1，相當低😍😍。
- 使用 MUX 重複利用加減運算 unit，以減少 ALU sub-units 的數量
