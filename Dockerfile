FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    VENV_DIR=/opt/venv \
    WEBUI_DIR=/opt/webui \
    DATA_DIR=/workspace/a1111-data \
    PORT=7860 \
    JUPYTER_PORT=8888

# OS deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip git wget curl ca-certificates \
    libgl1 libglib2.0-0 ffmpeg tzdata pciutils xxd && \
    rm -rf /var/lib/apt/lists/*

# Python venv
RUN python3 -m venv $VENV_DIR
ENV PATH="$VENV_DIR/bin:$PATH"

# PyTorch (CUDA 12.1) + xFormers (cu121 wheels)
RUN pip install --upgrade pip setuptools wheel && \
    pip install --index-url https://download.pytorch.org/whl/cu121 \
        torch torchvision torchaudio && \
    pip install --index-url https://download.pytorch.org/whl/cu121 \
        xformers

# ðŸ”§ Quiet + stability env (fewer warnings, stabler allocator)
ENV PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True,max_split_size_mb:128" \
    HF_HUB_DISABLE_TELEMETRY=1 \
    TOKENIZERS_PARALLELISM=false

# (Optional) extras: face restore + upscale (uncomment if you want them baked in)
# RUN pip install realesrgan gfpgan basicsr

# Pre-create persistent data dir (A1111 repo is cloned at runtime)
RUN mkdir -p $DATA_DIR

# Healthcheck for A1111
HEALTHCHECK --interval=30s --timeout=60s --start-period=60s --retries=10 \
  CMD curl -fsSL "http://localhost:${PORT}/" >/dev/null || exit 1

# Startup
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

# Defaults
ENV WEBUI_ARGS="--listen --port ${PORT} --api --data-dir ${DATA_DIR} --enable-insecure-extension-access --xformers" \
    ENABLE_JUPYTER=1 \
    JUPYTER_TOKEN= \
    JUPYTER_PORT=8888

EXPOSE 7860 8888
CMD ["/opt/start.sh"]
