#!/bin/bash
set -e

# Symlink all pre-cached models from the RunPod HF cache into ComfyUI model directories.
# The private HF repo "floppyshy-byte/prompt-studio-models" contains all models
# organized by category (checkpoints, loras, sams, ultralytics/bbox).

HF_CACHE="/runpod-volume/huggingface-cache/hub"
REPO="models--Floppyshy--prompt-studio-models"

if [ -f "$HF_CACHE/$REPO/refs/main" ]; then
    SNAP=$(cat "$HF_CACHE/$REPO/refs/main")
    BASE="$HF_CACHE/$REPO/snapshots/$SNAP"

    echo "[model-setup] Using cached HF snapshot: $SNAP"

    # Checkpoints
    if [ -d "$BASE/checkpoints" ]; then
        mkdir -p /comfyui/models/checkpoints
        for f in "$BASE/checkpoints"/*; do
            [ -e "$f" ] || continue
            target="/comfyui/models/checkpoints/$(basename "$f")"
            if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$f" ]; then
                ln -sf "$f" "$target"
                echo "[model-setup] Linked checkpoint: $(basename "$f")"
            fi
        done
    fi

    # LoRAs
    if [ -d "$BASE/loras" ]; then
        mkdir -p /comfyui/models/loras
        for f in "$BASE/loras"/*; do
            [ -e "$f" ] || continue
            target="/comfyui/models/loras/$(basename "$f")"
            if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$f" ]; then
                ln -sf "$f" "$target"
                echo "[model-setup] Linked LoRA: $(basename "$f")"
            fi
        done
    fi

    # SAM models
    if [ -d "$BASE/sams" ]; then
        mkdir -p /comfyui/models/sams
        for f in "$BASE/sams"/*; do
            [ -e "$f" ] || continue
            target="/comfyui/models/sams/$(basename "$f")"
            if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$f" ]; then
                ln -sf "$f" "$target"
                echo "[model-setup] Linked SAM: $(basename "$f")"
            fi
        done
    fi

    # Ultralytics models
    if [ -d "$BASE/ultralytics/bbox" ]; then
        mkdir -p /comfyui/models/ultralytics/bbox
        for f in "$BASE/ultralytics/bbox"/*; do
            [ -e "$f" ] || continue
            target="/comfyui/models/ultralytics/bbox/$(basename "$f")"
            if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$f" ]; then
                ln -sf "$f" "$target"
                echo "[model-setup] Linked ultralytics: $(basename "$f")"
            fi
        done
    fi
else
    echo "[model-setup] WARNING: HF cache not found at $HF_CACHE/$REPO/refs/main"
    echo "[model-setup] Models may not be available. Continuing anyway..."
fi

# Delegate to the original base-image startup (starts ComfyUI + handler)
exec "$@"
