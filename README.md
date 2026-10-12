# Autocomplete Worker (mlops-node-2.lan): Qwen2.5-Coder-7B-Instruct

This node serves low-latency fill-in-the-middle autocomplete. Its target GPU
is an NVIDIA RTX 3080 Ti with 12 GB GDDR6X. This repository currently builds a
CUDA `llama.cpp` server with a Q8_0 GGUF model, rather than the FP8 vLLM
configuration in the supplied cluster specification. The Dockerfile currently
targets NVIDIA Ada (compute capability 8.9), while the RTX 3080 Ti is Ampere
(8.6); rebuild for architecture 86 before using this image on that node. The
host must provide a working NVIDIA driver and NVIDIA Container Toolkit.

## Model and context

- Model: [`ggml-org/Qwen2.5-Coder-7B-Instruct-Q8_0-GGUF`](https://huggingface.co/ggml-org/Qwen2.5-Coder-7B-Instruct-Q8_0-GGUF),
  `qwen2.5-coder-7b-instruct-q8_0.gguf` (about 8.1 GB). This Q8_0 GGUF keeps
  the high precision intent of the original FP8 setup. The downloader pins the
  Hugging Face revision on first use, resumes partial downloads, and verifies
  the file against its LFS SHA256. Set `MODEL_REVISION` to a full commit SHA on
  the first download to select a specific revision; use a new volume to change
  the saved revision.
- The server defaults to an 8,192-token context and one parallel slot. The
  model's Q8_0 weights need about 8.1 GB before the KV cache and runtime
  buffers, so a 12 GB GPU may need a smaller context or fewer GPU layers. The
  server startup log reports actual GPU allocation.
- Runtime settings can be changed without rebuilding the image using
  `GPU_LAYERS`, `CTX_SIZE`, `PARALLEL`, `THREADS`, `BATCH_SIZE`,
  `UBATCH_SIZE`, `FLASH_ATTN`, `TEMP`, `TOP_P`, and `TOP_K`.

## Build and download

Run from the repository root. These examples use Podman; Docker can use the
same commands.

```sh
podman build --format docker -t qwen25-coder-7b-instruct-ada .
podman volume create qwen25-coder-7b-instruct-model
podman run --rm --gpus all \
  -v qwen25-coder-7b-instruct-model:/models \
  --entrypoint /usr/local/bin/download-model \
  qwen25-coder-7b-instruct-ada
```

The public model does not need a token. For authenticated downloads, pass
`HF_TOKEN` or `HUGGINGFACE_API_KEY` only to the download container. Model files
are stored in the named volume, not in the image or repository. Keep at least
10 GB free for the model volume.

## Run the server

```sh
podman run -d --name qwen25-coder-7b-instruct \
  --gpus all --shm-size 8g \
  -v qwen25-coder-7b-instruct-model:/models:ro \
  -p 127.0.0.1:8080:8080 \
  qwen25-coder-7b-instruct-ada
podman logs -f qwen25-coder-7b-instruct
```

Keep the API bound to loopback as shown. If it must be reachable remotely, put
it behind an authenticated TLS proxy.

Check readiness and make a small request after the model has loaded:

```sh
curl -fsS http://127.0.0.1:8080/health
curl -fsS http://127.0.0.1:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen2.5-coder-7b-instruct","messages":[{"role":"user","content":"Write a Python function that returns the first n Fibonacci numbers."}],"max_tokens":128,"temperature":0}'
```

## Validation status

The image has not been built or run on the target host. Confirm that the host
GPU supports compute capability 8.9 and verify model loading and a chat request
before relying on the service.
