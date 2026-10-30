分布式光纤传感 FPGA 实时解调系统 — 代码提交包

一、目录
01_FPGA：Vivado 工程、Verilog 采集逻辑、ADC/时钟 SPI 配置、XDC、Block Design 与构建脚本。
02_ZYNQ：Cortex-A9 裸机应用、NEON 数字下变频、DMA 双缓冲、lwIP UDP 与配套 BSP。
03_PC：MATLAB 实时 GUI/自动搜索/相位与频谱算法，Python IQ 接收与连续选点处理。
04_Firmware：已上板运行的 bit、elf、调试探针与 PS 初始化文件。
05_Reports：对应实现的时序、CDC 和 DRC 报告。

二、平台及配置
AX7350B / XC7Z035-2FFG676，FL9613 AD2_B，250 MSPS/12 bit。
同源外部 TRIG 1 kHz；80 MHz 拍频；每迹线 80000 原始点；25 点积分为 3200 IQ 点。
当前数字下变频在 ARM NEON，空间相位和 FFT 在 PC；FL9613 不包含 DA 输出。
ETH1 为 PS GEM0。PC 172.18.9.10/21，板端 172.18.9.11，UDP 50005/50006。
当前目标 MAC 2C-41-38-8B-32-B9，换电脑需在 02_ZYNQ/src/das_udp.c 核对目的地址。

三、构建与运行
FPGA：Vivado 2020.1。在根目录执行 vivado -mode batch -source 01_FPGA/build.tcl。
可直接打开 01_FPGA/net_test.xpr 查看逻辑和 Block Design。首次构建重新生成 IP，不需要历史缓存或增量 checkpoint。
ARM：原工程使用 xPack ARM GNU 10.3.1 工具链，设置 ARM_GCC_BIN 后执行 02_ZYNQ/build.ps1。
BSP 保留原配套头文件、静态库和驱动来源；更换编译器时需核对 hard-float ABI 和 BSP 配置。
JTAG：连接开发板后启动 hw_server，再执行 xsdb load_board.tcl。该脚本会复位板卡并下载固件，仅在确认目标板后手动运行。
主机：Python 3.11+，安装 03_PC/requirements.txt；MATLAB 参考 R2019a 环境。
配置网卡后执行 03_PC/start.ps1 -Python <python.exe> -Matlab <matlab.exe>。
停止执行 03_PC/stop.ps1。源码运行不要求已有 EXE；重新生成 GUI EXE 需 MATLAB Compiler。
输出保存在 03_PC/data，提交包不包含采集数据、运行库安装包及构建缓存。

四、核心逻辑
PL：三级触发同步、定长完整帧、64 bit ADC tick、异步 FIFO、AXIS/TLAST。
PS：S2MM DMA、DDR 双缓冲、先重新武装 DMA 再计算旧帧、80 MHz IQ 下变频与分包。
PC：全空间最高 FFT 谱峰搜索，两半窗与合并谱均 SNR>10 dB，实测覆盖率>=95%；持续性与3 dB滞回切换。
连续相位独立维护状态，5 Hz 高通和225 Hz低通，不以固定50 Hz拟合代替原始测量。
距离零点尚未独立校准；ADC外部I/O时序仍需专项验证；0.2 Hz尚未启用。

五、源码与第三方组件
ADC SPI、时钟配置及基础平台部分基于 ALINX 示例；处理器、DMA及网络驱动基于 Xilinx BSP/lwIP。
保留原文件中的版权、许可和免责声明。第三方 IP 需使用相应 Vivado 安装及许可，不另行提供工具安装文件。
01_FPGA 中包含基础工程遗留外围 IP；实际 DAS 网传使用 PS ETH1，而非其中的 PL Ethernet。
固件是已有实测版本；提交副本进行了工程路径重定位，完整重综合结果可能受工具与实现随机性影响。
SHA256SUMS.txt 用于核对提交文件完整性。

建议解压到短英文路径（如 D:/DAS_Code），避免 Vivado 旧版本的 Windows 路径长度限制。
