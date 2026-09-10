# QPSK ASCII Communication Experiment Design

## Purpose

Build the minimal reproducible MATLAB/Simulink experiment required by
`REQUIREMENTS.md`. The experiment transmits 8-bit ASCII through a Gray-coded
QPSK baseband link with root-raised-cosine pulse shaping, AWGN, and matched
filtering. It demonstrates correct text recovery and measures BER against the
coherent Gray-coded QPSK result in AWGN.

## Supported Environment

- MATLAB R2022b (9.13)
- Simulink 10.6
- Communications Toolbox 7.8
- DSP System Toolbox 9.15
- Signal Processing Toolbox 9.1

All selected APIs and Simulink block paths must be checked locally against this
installation before they are used. The generated model must run in R2022b.

## Architecture

Use a hybrid implementation:

1. Focused MATLAB functions provide a deterministic, testable reference path.
2. A programmatic model builder creates a readable submission-ready Simulink
   model that exposes the required communication nodes.
3. One configuration function supplies all shared experiment parameters.
4. Orchestration scripts run functional verification, the BER experiment,
   model verification, and report artifact generation.

The reference and Simulink paths use the same modulation convention and shared
parameters. No GUI, synchronization, channel coding, frequency offsets,
hardware deployment, or complex framing is included.

## Parameters and Conventions

- Default message: `HELLO HEU`
- Character representation: unsigned 8-bit ASCII, most-significant bit first
- QPSK: two bits per symbol, Gray mapping
- QPSK normalization: unit average symbol power
- RRC rolloff: 0.35
- Samples per symbol: 8
- Filter span: 10 symbols, centralized in configuration
- Eb/N0 sweep: 0:2:12 dB
- Functional test Eb/N0: a fixed high value selected to recover the default
  message exactly with the configured deterministic random seed
- Randomness: separate fixed seeds for the functional and BER experiments
- BER trials: deterministic batches continue until a configured minimum bit
  count is reached; the count must be sufficient to make the simulated curve
  useful over the required sweep without unbounded runtime

The modulation/demodulation convention is verified by an exhaustive four-symbol
unit test rather than inferred from constellation appearance.

## MATLAB Components

- `qpsk_config.m`: returns every shared numeric setting, seed, default text,
  and output/model path; validates internally fixed relationships.
- `ascii_to_bits.m`: validates 7-bit ASCII characters and emits an 8-bit,
  MSB-first column vector.
- `bits_to_ascii.m`: validates binary values and a length divisible by eight,
  then reconstructs text using the same bit ordering.
- `qpsk_modulate.m` and `qpsk_demodulate.m`: implement one documented Gray
  mapping with unit average power.
- `simulate_qpsk_link.m`: applies RRC transmit filtering, correctly scaled
  complex AWGN, matched filtering, total-delay removal, symbol sampling, and
  hard demodulation. It returns key-node signals for verification and plotting.
- `run_functional_demo.m`: runs the default ASCII message, asserts exact bit
  and text recovery, calculates BER, and writes demonstration data and figures.
- `run_ber_experiment.m`: uses long random bit streams independently of the
  short message, computes BER for 0:2:12 dB, evaluates
  `qfunc(sqrt(2*10.^(EbN0dB/10)))`, and saves numeric and plotted comparisons.
- `build_qpsk_model.m`: creates `model/qpsk_ascii_system.slx` using block paths
  and parameters verified in the local installation.
- `run_simulink_demo.m`: supplies input data, executes the model, extracts
  logged nodes, and verifies recovery.
- `run_all.m`: creates output directories, builds the model, runs both paths,
  and writes a final machine-readable and human-readable parameter/result
  summary.

Helpers remain small and local to their consumer unless reuse or direct testing
requires a separate file.

## Signal Processing and Data Flow

The functional chain is:

`ASCII text -> 8-bit stream -> Gray QPSK symbols -> RRC Tx filter -> AWGN ->`
`RRC matched filter -> delay removal/symbol sampling -> QPSK decisions -> bits -> text`

The two RRC filters each contribute half the total raised-cosine response delay.
The implementation retains filter tails, removes their combined deterministic
delay, and returns exactly one sample per transmitted symbol. AWGN variance is
derived from Eb/N0, two bits per symbol, unit symbol energy, and the sampled
complex-baseband convention. A no-noise case verifies filtering and indexing
independently of noise scaling.

## Simulink Model

The model is generated rather than manually edited so it can be reproduced.
It uses a simple left-to-right layout with descriptive subsystem/block names.
It exposes or logs at least:

- transmitted bits
- QPSK symbols
- transmit-filter waveform
- noisy receive waveform
- matched-filter output
- recovered symbols
- recovered bits

The model receives deterministic workspace/configuration inputs and uses a
finite simulation. Its output is checked against the transmitted data by
`run_simulink_demo.m`. ASCII source/decoding may be represented by verified
MATLAB-side input/output conversion if doing so keeps the block diagram clearer;
the saved model still visibly represents and runs the required physical chain.

## Report-Ready Results

`results/` is reproducibly regenerated and contains:

- transmitted and recovered text
- ASCII decimal/binary demonstration table
- transmitted and recovered bit comparison
- transmit constellation
- receive constellations at representative low, medium, and high Eb/N0 values
- I/Q or waveform plots at key nodes
- signal spectrum
- simulated and theoretical BER on one semilogarithmic plot
- numerical BER data in CSV and MAT form
- final parameter and result summaries
- debugging evidence from automated verification

Figures are saved as PNG for direct report use and FIG for later editing.
Labels are English for compatibility and consistent rendering.

## Validation and Failure Behavior

Public functions reject nonbinary inputs, incompatible vector lengths,
non-ASCII text, invalid numeric parameters, and unsupported shapes with named,
actionable errors. Orchestration scripts stop on any recovery, BER, model-build,
or model-run failure. Output directories are created when absent; existing
report artifacts with the same names are deterministically replaced.

## Verification Strategy

MATLAB unit tests are written before each corresponding implementation and
cover:

1. exact ASCII-to-bit ordering and round trip
2. all four QPSK bit-pair mappings and inverse decisions
3. no-noise RRC link recovery and output lengths
4. deterministic high-Eb/N0 message recovery
5. BER calculation and theoretical curve values
6. expected report artifacts and numeric schemas
7. generated model existence, required logged nodes, and successful execution

Each test is first observed failing for the intended missing behavior. Meaningful
increments are verified with `matlab -batch`. Final completion requires a fresh
full test run, a clean `run_all` execution, successful model execution, and an
artifact/requirements audit.

## Acceptance Criteria

- Every mandatory item in `REQUIREMENTS.md` is represented by a tested feature
  or a generated artifact.
- The default text is recovered exactly at the configured high Eb/N0.
- The no-noise bit error count is zero.
- Simulated BER is finite, nonincreasing within documented Monte Carlo
  variability, and reasonably consistent with the theoretical QPSK curve.
- `model/qpsk_ascii_system.slx` opens and runs in the installed R2022b version.
- A fresh `run_all` call regenerates the documented `results/` contents from
  repository sources and fixed configuration.
- No optional features prohibited by the specification are present.
