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

19 tests passed.

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
