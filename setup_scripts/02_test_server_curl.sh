#!/usr/bin/env bash
set -euo pipefail

curl -s http://127.0.0.1:8080/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "default",
    "messages": [{"role":"user","content":"Say hi in one short sentence."}],
    "temperature": 0.2,
    "max_tokens": 64
  }' | python3 -m json.tool