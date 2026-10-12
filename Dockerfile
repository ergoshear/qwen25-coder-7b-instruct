# syntax=docker/dockerfile:1
FROM vllm/vllm-openai:v0.30.0

ENV CUDA_VISIBLE_DEVICES=0 \
    VLLM_WORKER_MULTIPROCESS_METHOD=spawn \
    MODEL_REPO=RedHatAI/Qwen2.5-Coder-7B-Instruct-FP8-dynamic \
    MODEL_PATH=/models/checkpoint

COPY entrypoint.sh /usr/local/bin/model-entrypoint
COPY download-model.sh /usr/local/bin/download-model
RUN chmod 0755 /usr/local/bin/model-entrypoint /usr/local/bin/download-model

EXPOSE 8000
ENTRYPOINT ["/usr/local/bin/model-entrypoint"]
