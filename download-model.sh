#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
import json
import os
import re
from pathlib import Path

from huggingface_hub import HfApi, snapshot_download

repo = os.environ["MODEL_REPO"]
root = Path("/models")
root.mkdir(parents=True, exist_ok=True)
manifest = root / "model-source.json"
requested = os.environ.get("MODEL_REVISION", "")

if manifest.exists():
    saved = json.loads(manifest.read_text())
    if saved["repo"] != repo or (requested and saved["revision"] != requested):
        raise SystemExit("Model volume is pinned to another repo or revision; use a new volume.")
    revision = saved["revision"]
else:
    if requested and not re.fullmatch(r"[0-9a-f]{40}", requested):
        raise SystemExit("MODEL_REVISION must be a full Hugging Face commit SHA.")
    revision = requested or HfApi().model_info(repo).sha

snapshot_download(repo_id=repo, revision=revision, local_dir=root / "checkpoint")
temporary = manifest.with_suffix(".json.partial")
temporary.write_text(json.dumps({"repo": repo, "revision": revision}) + "\n")
temporary.replace(manifest)
print(f"Downloaded {repo} at {revision}")
PY
