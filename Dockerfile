FROM vllm/vllm-openai:latest

ENV CUDA_VISIBLE_DEVICES=0
ENV VLLM_WORKER_MULTIPROCESS_METHOD=spawn

EXPOSE 8000

# Launch vLLM with FP8 quantization to fit within 12GB VRAM while maximizing throughput
ENTRYPOINT ["python3", "-m", "vllm.entrypoints.openai.api_server"]
CMD ["--model", "Qwen/Qwen2.5-Coder-7B-Instruct-FP8", \
     "--quantization", "fp8", \
     "--max-model-len", "8192", \
     "--gpu-memory-utilization", "0.95"]
