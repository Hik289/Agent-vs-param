#!/bin/bash
# Reproduce the main R3 Stage D paper result: 5 methods × ToolDAGWorld × n=220.
# Wall time: ~3 hours single-key; cost: ~$30-50 (gpt-4o-mini).

set -e
ENVPROBE_ROOT="${ENVPROBE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ENVPROBE_ROOT"

: "${OPENAI_API_KEY:?Please set OPENAI_API_KEY before running}"

mkdir -p experiments logs

# Spine 5 methods
python -m src.scripts.run_main \
    --registry experiments/cells_registry.csv \
    --layer r3_stage_d --prefix r3_stage_d \
    --parallel 8 2>&1 | tee logs/r3_stage_d_run.log

# Ablation 4 variants
python -m src.scripts.run_main \
    --registry experiments/cells_registry.csv \
    --layer r3_stage_d_ablation --prefix r3_stage_d_ablation \
    --parallel 8 2>&1 | tee logs/r3_stage_d_ablation_run.log

# Oracle task-weighted
python -m src.scripts.run_main \
    --registry experiments/cells_registry.csv \
    --layer r3_stage_d_tw --prefix r3_stage_d_tw \
    --parallel 6 2>&1 | tee logs/r3_stage_d_tw_run.log

# Stats + render markdown
python analysis/r3_stage_d_stats.py
python analysis/r3_render_md.py

echo ""
echo "Done. Main result in analysis/stat_results_r3_final.md"
