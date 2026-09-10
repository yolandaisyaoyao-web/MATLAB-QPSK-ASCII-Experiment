# QPSK ASCII Communication Experiment

## 1. Project

Course: 通信系统综合实验 A-射频综合

Topic:
射频题目1：QPSK发送与接收ASCII码设计与实现

The final project must be implemented primarily with MATLAB/Simulink.

## 2. Mandatory course requirements

The project must:

1. Implement QPSK transmission and reception of ASCII data.
2. Define measurable technical/performance indicators.
3. Provide simulation results at key system nodes.
4. Provide a Simulink model and corresponding project files.
5. Produce sufficient experimental results for a final report longer than 12 pages.
6. Preserve module parameters, node results, measurements and debugging evidence for the final report.

## 3. Required communication chain

Core system:

ASCII text
-> 8-bit ASCII binary stream
-> Gray-coded QPSK mapping
-> Root Raised Cosine transmit filtering
-> AWGN channel
-> Root Raised Cosine receive/matched filtering
-> QPSK demodulation
-> recovered bit stream
-> ASCII decoding
-> recovered text

The first implementation may assume ideal carrier and symbol synchronization.

Do not add carrier synchronization, timing synchronization, frequency offset compensation, GUI or complex framing until the core system is fully verified.

## 4. Initial design parameters

Use these as initial values unless the installed MATLAB version requires a justified change:

- Modulation: QPSK
- Mapping: Gray
- Bits per symbol: 2
- ASCII encoding: 8 bits/character
- Default message: HELLO HEU
- RRC rolloff factor: 0.35
- Samples per symbol: 8
- Eb/N0 sweep: 0:2:12 dB
- High-SNR functional test: sufficiently high Eb/N0 to obtain deterministic correct recovery

Keep important parameters centralized rather than duplicated across scripts.

## 5. Required functional verification

The project must verify:

- ASCII -> bits conversion is correct.
- QPSK modulation/demodulation mapping is consistent.
- At sufficiently high Eb/N0, the recovered text equals the transmitted text.
- Transmitted and recovered bit streams can be compared.
- BER can be calculated correctly.

## 6. Required performance experiment

Measure simulated BER versus Eb/N0.

Compare it with the theoretical Gray-coded coherent QPSK BER in AWGN:

Pb = Q(sqrt(2*Eb/N0))

Theoretical and simulated BER shall be shown on the same semilogarithmic plot.

Use enough random bits for meaningful BER measurements.
The short ASCII message is for functional demonstration, not for estimating the BER curve.

## 7. Required report-ready outputs

Save reproducible results under results/.

At minimum produce:

- transmitted ASCII text and recovered ASCII text
- ASCII/binary data demonstration
- transmit QPSK constellation
- representative receive constellations at low, medium and high Eb/N0
- relevant I/Q or waveform plots at key nodes
- transmit or received signal spectrum
- BER versus Eb/N0: theory and simulation
- numerical BER data
- final parameter summary

Use meaningful filenames.

## 8. Simulink requirements

A readable Simulink model must be generated and saved under model/.

The model must expose/log the important nodes required for the experimental report.

Prefer a simple left-to-right communication-chain layout.

The final Simulink model must be runnable on the user's installed MATLAB version.

Do not assume block library paths or parameters without verifying them locally.

## 9. MATLAB requirements

Use MATLAB scripts for:

- configuration
- functional verification
- automated Simulink execution where practical
- BER sweep
- numerical analysis
- automatic generation of report-ready figures

Prefer MATLAB batch execution for automated verification.

## 10. Scope control

Priority order:

1. Correct ASCII round trip
2. Correct QPSK system
3. Correct Simulink model
4. BER experiment
5. Report-ready figures
6. Optional enhancement only if all above are stable

Do not over-engineer the project.