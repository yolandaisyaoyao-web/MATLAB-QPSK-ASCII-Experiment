# MATLAB/Simulink QPSK ASCII Communication System

## Overview

This project implements a QPSK-based ASCII communication system using MATLAB and Simulink.

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
- Automated MATLAB tests


## Verification

17 tests passed.

Recovered message:

HELLO HEU


## Project Structure

src/
MATLAB implementation

model/
Simulink model

tests/
Automated verification

results/
Figures and experiment data