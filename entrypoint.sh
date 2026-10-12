#!/usr/bin/env bash
set -euo pipefail

exec python3 -m vllm.entrypoints.openai.api_server \
    --model "${MODEL_PATH:-/models/checkpoint}" \
    --served-model-name qwen2.5-coder-7b-instruct \
    --max-model-len "${MAX_MODEL_LEN:-8192}" \
    --gpu-memory-utilization "${GPU_MEMORY_UTILIZATION:-0.95}" \
    --host 0.0.0.0 --port 8000 \
    "$@"
