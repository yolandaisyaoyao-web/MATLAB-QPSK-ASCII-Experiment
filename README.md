# MATLAB/Simulink QPSK ASCII Communication System

## Overview

This project implements a QPSK-based ASCII communication system using MATLAB,
Simulink, and a MATLAB App Designer interface.

The complete chain:

ASCII
→ Bit conversion
→ Gray QPSK modulation
→ RRC filtering
→ AWGN channel
→ Matched filtering
→ QPSK demodulation
→ ASCII recovery


## Environment

- MATLAB R2022b
- Simulink
- Communications Toolbox


## Features

- ASCII transmission and recovery
- Gray-coded QPSK modulation/demodulation
- Root-raised cosine filtering
- AWGN channel simulation
- BER performance analysis
- Simulink implementation
- Chinese MATLAB App Designer interface for interactive message simulation
- Automated MATLAB tests


## Interactive App

Open `app/QPSK_ASCII_App.mlapp` in MATLAB App Designer, or run:

```matlab
addpath('app'); QPSK_ASCII_App
```

The App interface, constellation title, axis labels, and status messages use
Chinese by default for experiment demonstrations and report screenshots.
Future experiment-facing figures and interface copy should prefer Chinese;
filenames, variable names, and required technical symbols such as QPSK, BER,
and Eb/N0 may remain English.


## Verification

20 tests passed.

Recovered message:

HELLO HEU


## Project Structure

src/
MATLAB implementation

model/
Simulink model

app/
Chinese MATLAB App Designer interface

tests/
Automated verification

results/
Figures and experiment data


## 报告图片与本地资料

- `results/figures/`：原始实验图。
- `results/report_figures/`：根据现有数值结果自动生成的中文报告级图片（白色背景、300 dpi PNG）。
- `docs/report/assets/figures/`：最终实验报告使用的精选图片。
- `docs/report/reference/`：本地课程资料，仅供编写报告时参考，不上传公开仓库。

无需重新运行或修改通信算法，可从现有数值结果重新生成报告级图片：

```matlab
addpath('src'); generate_report_figures(qpsk_config())
```

带编号的中文文件名涵盖发送星座图、低/高信噪比接收星座图、BER 曲线、关键节点波形和信号频谱。
