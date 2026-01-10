#!/usr/bin/env bash
set -euo pipefail

# System deps for building llama.cpp + Python venv
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  git build-essential cmake \
  python3 python3-venv python3-pip \
  curl ca-certificates \
  libcurl4-openssl-dev

# Get llama.cpp
if [ ! -d "llama.cpp" ]; then
  git clone https://github.com/ggml-org/llama.cpp.git
fi

# Build (CPU-only minimal build)
cmake -S llama.cpp -B llama.cpp/build -DCMAKE_BUILD_TYPE=Release
cmake --build llama.cpp/build -j"$(nproc)"

echo "Built binaries should be under: llama.cpp/build/bin/"