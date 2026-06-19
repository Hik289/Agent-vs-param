#!/bin/bash
# Smoke test: 1 episode × 3 envs × 1 method (no_probe), gpt-4o-mini, ~2 min, ~$0.01.
# Verifies environment setup, LLM connectivity, and metric pipeline end-to-end.

set -e
ENVPROBE_ROOT="${ENVPROBE_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
cd "$ENVPROBE_ROOT"

: "${OPENAI_API_KEY:?Please set OPENAI_API_KEY before running}"

mkdir -p experiments/_smoke

for env in ObjectStateWorld ToolDAGWorld GraphNavWorld; do
    echo "=== Smoke: $env ==="
    python -m src.scripts.run_smoke \
        --env "$env" --method no_probe \
        --stress S2 --n-seeds 1 --prefix _smoke/${env}_smoke
done

echo ""
echo "Smoke test complete. Check experiments/_smoke/ for jsonl outputs."
