# Artifact Guide

Operational notes for reproducing `Agent vs. Parametric World Models` from the public `Agent-vs-param` repository.

## Review Path

- `src/`: Core source code and reusable implementations.
- `examples/`: Small runnable examples and smoke-test entry points.
- `figures/`: README and paper-facing figures.

## Environment Files

- `requirements.txt`: Primary Python dependency list.

## Smoke Checks

Run these checks before long jobs:

```bash
python -m compileall -q .
python -m pytest src/tests -q
bash examples/smoke_test.sh
python src/scripts/run_smoke.py
```

## Reproduction Entry Points

Main tracked entry points for paper-scale or benchmark-scale runs:

- `bash examples/reproduce_main.sh`

## Figure Assets

- `figures/fig_intuition_gemini.pdf`
- `figures/fig_intuition_gemini.png`

## Data And Outputs

- API-backed runs should read credentials from environment variables or local `.env` files only; never commit real keys or provider-specific secrets.
- Record provider endpoint, model/deployment name, sampling parameters, and execution date for every API-backed table or figure.
- Treat generated JSONL files, logs, caches, model checkpoints, and benchmark downloads as local artifacts unless explicitly tracked as fixtures.
- For stochastic experiments, record seeds, task counts, dataset splits, and the exact git commit used for the run.

## Reporting Checklist

- `git rev-parse HEAD`
- Python version and dependency-install command
- Full command line for every table, figure, or benchmark cell
- Paths to raw outputs and aggregation scripts
- External data, benchmark, or API-backed steps that were intentionally skipped
