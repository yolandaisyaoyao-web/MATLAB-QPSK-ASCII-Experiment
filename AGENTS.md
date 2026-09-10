# Project Instructions

Read REQUIREMENTS.md before implementing or changing the experiment.

## Priorities

Correctness > reproducibility > simplicity > extra features.

Implement only what is necessary for the experiment.
Do not add optional features before all core tests pass.

## Workflow

- Work incrementally.
- Verify each meaningful change with local MATLAB execution.
- Prefer `matlab -batch` for automated checks.
- Inspect the installed MATLAB version/toolboxes before assuming APIs or Simulink block paths.
- Prefer local MATLAB help/metadata before web search.
- Do not browse the web unless a MATLAB API/version issue cannot be resolved locally.
- Keep shared experiment parameters centralized.
- Save reproducible report-ready figures and metrics under results/.
- Preserve the `.slx` model required for course submission.

## Presentation Language

- The project includes a MATLAB App Designer interface under `app/`.
- The App uses Chinese by default.
- Prefer Chinese for future experiment demonstrations, figure titles, axis labels, and user-facing interface copy.
- Filenames, variable names, and required technical symbols may remain English.

## Communication

Keep responses concise.

At the end of each task report only:
1. files changed,
2. verification performed,
3. result,
4. blocker, if any.

Do not provide long tutorials unless explicitly requested.

If a routine engineering choice can safely be made, make it and document it instead of asking the user.

## Scope

Keep the existing App Designer interface limited to experiment presentation.
Do not add other GUI features, synchronization algorithms, complex frame
protocols, hardware deployment, channel coding or unrelated abstractions
unless explicitly requested.
