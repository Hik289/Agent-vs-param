# EnvProbe: When LLM Agents Should Actively Probe the Environment

> [paper link placeholder] | [project page placeholder]

## Overview

EnvProbe studies when LLM agents should sacrifice action budget to actively probe environment state for belief calibration. We find a fundamental Pareto trade-off between belief accuracy and task success.

**Key findings:**

- Probe-action budget is a fundamental constraint in long-horizon tasks where every probe costs one act step.
- A 4-dimensional probe-target score (criticality + staleness + uncertainty + dependency role) achieves **+11.76 pp** belief-accuracy gain over Periodic-Probe baseline (n=220 per cell, paired bootstrap p < 0.001).
- Pareto frontier analysis reveals **7 methods are jointly optimal** on procedural (ToolDAGWorld) tasks under the A_H vs task-success objective pair.
- Spatial-belief tasks (short-chain ObjectStateWorld / GraphNavWorld) show that the **(c + d) two-dimensional variant** is Pareto-dominant.

## Quick Start

```bash
# 1. Install
pip install -r requirements.txt
export OPENAI_API_KEY=...        # Required for LLM agent
export ANTHROPIC_API_KEY=...     # Optional, for Judge variant
export ENVPROBE_ROOT=$(pwd)      # Optional, default is repository root

# 2. Smoke test (1 episode, ToolDAGWorld, no probing)
python -m src.scripts.run_smoke \
    --env ToolDAGWorld --method no_probe \
    --stress S2 --n-seeds 1 --prefix smoke

# 3. Anchor regression suite (determinism + oracle self-check)
python src/scripts/anchor_3_determinism.py
python src/scripts/anchor_4_oracle_self_check.py

# 4. Reproduce R3 Stage D main result (n=220, ~3h on a single LLM key)
python -m src.scripts.run_main \
    --registry experiments/cells_registry.csv \
    --layer r3_stage_d --prefix r3_stage_d --parallel 8
```

## Directory Structure

```
envprobe/
├── src/
│   ├── environments/    # 3 worlds: ToolDAGWorld, GraphNavWorld, ObjectStateWorld
│   ├── methods/         # 9 probe-selection methods + 4 ablation variants
│   ├── metrics/         # A_H, task_success, drift, oracle
│   ├── agents/          # LLM agent prompts + parser (R3 fix)
│   ├── scripts/         # run_main.py, run_smoke.py, anchor_*, verify_floor.py
│   ├── tests/           # Anchor 1-5 + ToolDAG no-repeat + scoring invariants
│   └── utils/           # api_client (OpenAI + Anthropic wrappers), io helpers
├── analysis/            # Statistical pipeline + R3 Stage D stats + Pareto
├── examples/            # Smoke + paper-reproduction shell scripts
├── config.yaml          # Default LLM model + budget defaults
├── requirements.txt
├── LICENSE
└── README.md
```

## Methods Included

| Method | Description |
|---|---|
| `no_probe` | Always act; no probing. |
| `random_probe` | Each step, probe with prob 1/4 of a random valid probe verb. |
| `periodic_probe` | Probe every k steps (k = horizon / 4). |
| `self_uncertainty_probe` | Probe when LLM-reported belief confidence < 0.5. |
| `envprobe_simple` | 4-dim score: criticality + staleness + (1-conf) + dependency role. |
| `envprobe_simple_cd` | 2-dim ablation: criticality + dependency role only. |
| `envprobe_simple_minus_{c,s,u,d}` | Single-dim leave-one-out ablation. |
| `envprobe_judge` | LLM judge decides probe vs act using belief-vs-action consistency. |
| `oracle_probe` | Cheats: picks probe targeting largest belief-vs-gold mismatch. Uniform utility. |
| `oracle_task_weighted` | Improved oracle using task-progress-weighted utility. |

## Environments

| Env | Belief stratum | Task | Horizon |
|---|---|---|---|
| `ObjectStateWorld` | spatial | Pick up a goal object in a multi-room locked-door world. | 30 |
| `GraphNavWorld` | spatial | Navigate from start to goal node on a locked-edge graph. | 30 |
| `ToolDAGWorld` | procedural | Chain tools t_0 ... t_8 to produce a target variable. | 30 |

All envs implement the same `Environment` interface in `src/environments/base.py`.

## Reproducing Paper Results

Place the data archive `envprobe_data_v1/` (episode JSONLs + cells_registry) at the repository root, then:

```bash
# G1: stratified A_H gain over Periodic (n=220 per cell, paired bootstrap)
python -m src.scripts.run_main --registry experiments/cells_registry.csv --layer r3_stage_d --prefix r3_stage_d --parallel 8

# N1 ablation
python -m src.scripts.run_main --registry experiments/cells_registry.csv --layer r3_stage_d_ablation --prefix r3_stage_d_ablation --parallel 8

# Task-weighted Oracle (Cell B)
python -m src.scripts.run_main --registry experiments/cells_registry.csv --layer r3_stage_d_tw --prefix r3_stage_d_tw --parallel 6

# Final stats (paired bootstrap + McNemar + Bonferroni–Holm)
python analysis/r3_stage_d_stats.py
python analysis/r3_render_md.py
```

The final markdown report `analysis/stat_results_r3_final.md` contains all paper numbers.

## Extending

- **New environment**: subclass `src.environments.base.Environment`. Implement `reset`, `step_task_action`, `step_probe_action`, `get_observation`, `get_gold_state`, `score_belief_state`, `task_description`, `available_task_actions`, `available_probe_actions`.
- **New probe method**: subclass `src.methods.base.Method`. Implement `decide(ctx) -> MethodDecision`.
- **New metric**: extend `src.metrics.scorer.score_step` / `score_episode`.

## Notes on the Stage B Agent Fix

After diagnosing that LLM agents become stuck in single-tool loops on ToolDAGWorld, two changes were made (see `analysis/r3_tooldag_agent_failure_diagnosis.md`):

1. `ToolDAGWorld._call_tool` now returns `valid=False` with `reason="already_completed"` when an agent tries to re-call an already-completed tool, providing learning signal.
2. The system prompt in `src/agents/prompts.py` gained a ToolDAGWorld-specific section guiding the agent to maintain `completed_subgoals` / `open_dependencies` belief fields and to plan backwards from the target variable.

Both changes preserve the anchor_3 hash determinism (120 / 120) and pass anchor_4 oracle self-check.

## Citation

```bibtex
[BibTeX placeholder — will be added on publication]
```

## License

MIT. See `LICENSE`.
