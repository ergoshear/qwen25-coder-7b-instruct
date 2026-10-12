# Qwen2.5-Coder-7B-Instruct on mlops-node-2.lan

This image serves an FP8 checkpoint with vLLM 0.30.0 on the RTX 3080 Ti (CUDA
compute capability 8.6). It provides an OpenAI-compatible API on port 8000.

## Model and runtime

- Checkpoint: [RedHatAI/Qwen2.5-Coder-7B-Instruct-FP8-dynamic](https://huggingface.co/RedHatAI/Qwen2.5-Coder-7B-Instruct-FP8-dynamic).
  The proposed `Qwen/Qwen2.5-Coder-7B-Instruct-FP8` repository was not
  available, so this published quantization of the same instruction model is
  used instead.
- vLLM detects the checkpoint's quantization configuration. On Ampere,
  vLLM documents weight-only W8A16 execution through FP8 Marlin; native
  FP8 W8A8 requires a newer GPU. Verify the selected kernel in the startup log.
- Default context: 8,192 tokens. `MAX_MODEL_LEN` and
  `GPU_MEMORY_UTILIZATION` override runtime defaults.
- The downloader saves the complete Hugging Face revision on first use in
  `/models/model-source.json`. Set `MODEL_REVISION` to a full commit SHA on
  the first download. Use a fresh volume to change it.

The model and KV cache must fit in 12 GB. If vLLM rejects the requested
capacity, lower `MAX_MODEL_LEN` or `GPU_MEMORY_UTILIZATION` and test latency
on the target host. The image has not been run there yet.

## Build and run

Run these commands on the target Linux node. The GitHub workflow builds the
same image on an x86-64 runner.

```sh
docker build -t qwen25-coder-7b-instruct .
docker volume create qwen25-coder-7b-model
docker run --rm -v qwen25-coder-7b-model:/models \
  --entrypoint /usr/local/bin/download-model qwen25-coder-7b-instruct
docker run --rm --gpus all --shm-size 8g \
  -v qwen25-coder-7b-model:/models:ro \
  -p 127.0.0.1:8000:8000 qwen25-coder-7b-instruct
```

The host needs a working NVIDIA driver and NVIDIA Container Toolkit. Pass
`HF_TOKEN` only to the download command if access is restricted.

```sh
curl -fsS http://127.0.0.1:8000/health
curl -fsS http://127.0.0.1:8000/v1/models
```

Kubernetes manifests are staged in `gitops/apps/qwen25-coder-7b-instruct/`
and are not included in the active GitOps app list yet.
