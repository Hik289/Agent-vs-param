<div align="center">

# Grounded Iterative Language Planning: How Parameterized World Models Reduce Hallucination Propagation in LLM Agents

**Xinyuan Song, Zekun Cai**

[![arXiv](https://img.shields.io/badge/arXiv-2606.27806-b31b1b.svg)](https://arxiv.org/abs/2606.27806)
[![Paper](https://img.shields.io/badge/Paper-PDF-blue.svg)](https://arxiv.org/pdf/2606.27806)
[![Code](https://img.shields.io/badge/GitHub-Code-black.svg)](https://github.com/Hik289/Environment-reduce-error)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**Official implementation for "Grounded Iterative Language Planning."**

</div>

---

## Overview

Language agents often plan by imagining state transitions in natural language.
When those imagined transitions are wrong, hallucinated state changes can
propagate through the rest of the plan. This repository provides the experimental
harness for studying that failure mode on graph-structured planning tasks and
for evaluating grounded planning strategies that use environment-side signals to
reduce propagation error.

The paper compares API-based agent world models with parameterized transition
models, then introduces **Grounded Iterative Language Planning (GILP)**: a hybrid
planning loop where an LLM proposes actions and imagined deltas while a smaller
grounded model supplies valid actions, predicted state deltas, risk, and value.
A consistency gate asks the LLM to revise when the two disagree.

In the paper, GILP reduces hallucinated-state rate from **0.176 to 0.035** on
real GPT-4o-mini calls, and calibrated simulator ablations raise success from
**0.668 to 0.838** with only about **22%** additional LLM calls.

---

## Repository Contents

This public snapshot contains the graph-world evaluation harness, LLM agent
runner, probing and oracle baselines, scoring code, and reproduction scripts used
for the grounded planning experiments.

| Component | Location | Purpose |
|-----------|----------|---------|
| Environments | `src/environments/` | Object, graph navigation, and tool-DAG planning worlds. |
| Agents | `src/agents/` | GPT-style agent prompts, parsing, and API wrappers. |
| Methods | `src/methods/` | No-probe, periodic, uncertainty, EnvProbe-style, judge, and oracle policies. |
| Metrics | `src/metrics/` | Belief accuracy, task success, drift, oracle, and aggregate scoring. |
| Scripts | `src/scripts/` | Smoke tests, anchor checks, main experiment runner, and diagnostics. |
| Registry | `cells_registry.csv` | Experiment cells for environments, methods, stress settings, and seeds. |
| Examples | `examples/` | Shell entry points for smoke and paper-scale reproduction runs. |

---

## Method Summary

GILP-style grounded planning is motivated by a simple observation: pure
language-world-model rollouts are flexible, but their errors are hard to score;
parameterized world models are easier to measure with transition losses and
validity metrics, but are weaker as standalone planners. The hybrid loop keeps
the LLM in charge of high-level reasoning while grounding each step against
model-independent environment signals.

| Regime | Description |
|--------|-------------|
| **Agent world model** | The LLM reasons directly over text observations and imagined state changes. |
| **Parameterized world model** | A trained transition predictor estimates valid actions, deltas, risk, and value. |
| **Grounded iterative planning** | The LLM drafts an action/delta, the grounded model checks consistency, and the LLM revises when needed. |

The code exposes several planning and probing baselines that can be used to
measure hallucination propagation, belief calibration, and task success.

| Method | Description |
|--------|-------------|
| `no_probe` | Always act; never spends budget on checking state. |
| `random_probe` | Uses a random valid probe with fixed probability. |
| `periodic_probe` | Probes every fixed interval. |
| `self_uncertainty_probe` | Probes when the LLM reports low belief confidence. |
| `envprobe_simple` | Scores probe targets by criticality, staleness, uncertainty, and dependency role. |
| `envprobe_simple_cd` | Two-dimensional ablation using criticality and dependency role. |
| `envprobe_simple_minus_{c,s,u,d}` | Leave-one-dimension-out ablations. |
| `envprobe_judge` | Uses an LLM judge to decide whether to probe or act. |
| `oracle_probe` | Oracle upper bound based on belief-vs-gold mismatch. |
| `oracle_task_weighted` | Oracle variant weighted by task progress utility. |

---

## Environments

| Environment | Planning structure | Task |
|-------------|--------------------|------|
| `ObjectStateWorld` | Spatial object and door state | Pick up a target object in a multi-room world. |
| `GraphNavWorld` | Locked-edge graph navigation | Navigate from start to goal under partial state information. |
| `ToolDAGWorld` | Procedural dependency graph | Chain tools to produce a target variable. |

Each environment implements the common interface in `src/environments/base.py`.

---

## Installation

```bash
git clone git@github.com:Hik289/Environment-reduce-error.git
cd Environment-reduce-error

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

export OPENAI_API_KEY=sk-...        # required for GPT-based agents
export ANTHROPIC_API_KEY=...        # optional, for Anthropic/Judge variants
export ENVPROBE_ROOT=$(pwd)         # optional; defaults to repository root
```

The default model in `config.yaml` is `gpt-4o-mini`.

---

## Quickstart

Run a small end-to-end smoke test:

```bash
bash examples/smoke_test.sh
```

Or run one explicit cell:

```bash
python -m src.scripts.run_smoke \
    --env ToolDAGWorld \
    --method no_probe \
    --stress S2 \
    --n-seeds 1 \
    --prefix smoke
```

Run deterministic and oracle sanity checks:

```bash
python src/scripts/anchor_3_determinism.py
python src/scripts/anchor_4_oracle_self_check.py
```

---

## Reproducing Experiments

The included registry defines the environment, stress, method, and seed grid:

```bash
python -m src.scripts.run_main \
    --registry cells_registry.csv \
    --layer r3_stage_d \
    --prefix r3_stage_d \
    --parallel 8
```

The example script runs the broader reproduction pipeline:

```bash
bash examples/reproduce_main.sh
```

Outputs are written under `experiments/` and `logs/`. Depending on the selected
layer and API rate limits, full runs may take several hours and incur LLM API
costs.

---

## Directory Structure

```text
Environment-reduce-error/
|-- README.md
|-- LICENSE
|-- requirements.txt
|-- config.yaml
|-- cells_registry.csv
|-- examples/
|   |-- smoke_test.sh
|   `-- reproduce_main.sh
`-- src/
    |-- agents/
    |-- environments/
    |-- methods/
    |-- metrics/
    |-- scripts/
    |-- tests/
    `-- utils/
```

---

## Citation

If you use this code, please cite the paper:

```bibtex
@misc{song2026groundediterativelanguageplanning,
  title         = {Grounded Iterative Language Planning: How Parameterized World Models Reduce Hallucination Propagation in LLM Agents},
  author        = {Xinyuan Song and Zekun Cai},
  year          = {2026},
  eprint        = {2606.27806},
  archivePrefix = {arXiv},
  primaryClass  = {cs.AI},
  url           = {https://arxiv.org/abs/2606.27806}
}
```

## License

Released under the [MIT License](LICENSE). Third-party models, APIs, and
benchmarks used by the experiments are governed by their own licenses and terms.
