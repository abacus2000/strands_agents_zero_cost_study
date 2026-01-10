#!/usr/bin/env bash
set -euo pipefail

# Choose one:
# Option A (small-ish): gemma 1B instruct GGUF (downloaded automatically)
MODEL_HF="ggml-org/gemma-3-1b-it-GGUF"

# Start server on 8080 with a reasonable context window.
# --jinja is commonly used to enable jinja chat templates (also shown in Strands' llama.cpp setup example).
./llama.cpp/build/bin/llama-server \
  -hf "${MODEL_HF}" \
  --host 127.0.0.1 \
  --port 8080 \
  -c 4096 \
  --jinja