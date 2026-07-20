# Artifact Guide

This guide maps the public `Agent-vs-param` repository to a reviewer-friendly artifact workflow for `Agent vs. Parametric World Models`. It is meant to make the release easier to inspect in the style of ICML, ICLR, NeurIPS, and similar artifact-review processes.

## What To Inspect First

- `src/`: Core source code and reusable implementations.
- `examples/`: Small runnable examples and smoke-test entry points.
- `figures/`: README and paper-facing figures.

## Environment Files

- `requirements.txt`: Primary Python dependency list.

## Minimal Verification

Run these checks in a fresh environment before launching expensive jobs:

```bash
python -m compileall -q .
python -m pytest src/tests -q
bash examples/smoke_test.sh
python src/scripts/run_smoke.py
```

## Reproduction And Analysis Entry Points

These are the main tracked files to inspect for paper-scale or benchmark-scale reproduction. Some require arguments, credentials, downloaded benchmarks, or local data paths described in the README.

- `bash examples/reproduce_main.sh`

## Figure Assets

- `figures/fig_intuition_gemini.pdf`
- `figures/fig_intuition_gemini.png`

## Data, Credentials, And Generated Outputs

- API-backed runs should read credentials from environment variables or local `.env` files only; never commit real keys or provider-specific secrets.
- Record provider endpoint, model/deployment name, sampling parameters, and execution date for every API-backed table or figure.
- Treat generated JSONL files, logs, caches, model checkpoints, and benchmark downloads as local artifacts unless explicitly tracked as fixtures.
- For stochastic experiments, record seeds, task counts, dataset splits, and the exact git commit used for the run.

## Reviewer Reporting Checklist

- `git rev-parse HEAD`
- Python version and dependency-install command
- Full command line for every table, figure, or benchmark cell
- Paths to raw outputs and aggregation scripts
- External data, benchmark, or API-backed steps that were intentionally skipped
