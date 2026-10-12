#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
    exec /opt/llama/bin/llama-server \
        --model /models/qwen2.5-coder-7b-instruct-q8_0.gguf \
        --alias qwen2.5-coder-7b-instruct \
        --host 0.0.0.0 --port 8080 \
        --n-gpu-layers "${GPU_LAYERS:-99}" \
        --ctx-size "${CTX_SIZE:-8192}" \
        --parallel "${PARALLEL:-1}" \
        --threads "${THREADS:-8}" \
        --batch-size "${BATCH_SIZE:-512}" \
        --ubatch-size "${UBATCH_SIZE:-128}" \
        --flash-attn "${FLASH_ATTN:-on}" --jinja \
        --temp "${TEMP:-0.7}" --top-p "${TOP_P:-0.8}" --top-k "${TOP_K:-20}"
fi

exec /opt/llama/bin/llama-server "$@"
