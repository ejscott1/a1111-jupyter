# ---------- Base ----------
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

# ---------- OS deps ----------
# - build-essential/cmake: lets wheels compile if prebuilt wheels are unavailable
# - git-lfs: makes pulling large model files easier (optional but handy)
# - libgl1, libglib2.0-0, ffmpeg: common runtime deps for cv/vis stuff
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-pip \
    git git-lfs wget curl ca-certificates \
    build-essential cmake \
    libopenblas-dev liblapack-dev \
    libgl1 libglib2.0-0 ffmpeg tzdata pciutils xxd \
 && rm -rf /var/lib/apt/lists/*

# ---------- Python venv ----------
RUN python3 -m venv $VENV_DIR
ENV PATH="$VENV_DIR/bin:$PATH"

# ---------- PyTorch (CUDA 12.1) + xFormers ----------
RUN pip install --upgrade pip setuptools wheel && \
    pip install --index-url https://download.pytorch.org/whl/cu121 \
        torch torchvision torchaudio && \
    pip install --index-url https://download.pytorch.org/whl/cu121 \
        xformers

# ---------- CV / InsightFace stack (for FaceID/IP-Adapter) ----------
# Notes:
# - pin numpy<2 because many wheels (onnxruntime/opencv) are still commonly tested on 1.x
# - onnxruntime (CPU) is fine for InsightFace; keep it matching stable combos
# - opencv-python-headless avoids pulling X11/GUI junk
RUN pip install \
      "numpy<2" \
      "onnxruntime==1.16.3" \
      "opencv-python-headless==4.8.0.76" \
      "insightface>=0.7.3"

# ---------- QoL env ----------
ENV PYTORCH_CUDA_ALLOC_CONF="expandable_segments:True,max_split_size_mb:128" \
    HF_HUB_DISABLE_TELEMETRY=1 \
    TOKENIZERS_PARALLELISM=false

# (Optional) extras: face restore + upscale
# RUN pip install realesrgan gfpgan basicsr

# ---------- Persistent data dir ----------
RUN mkdir -p $DATA_DIR

# ---------- Healthcheck ----------
HEALTHCHECK --interval=30s --timeout=60s --start-period=60s --retries=10 \
  CMD curl -fsSL "http://localhost:${PORT}/" >/dev/null || exit 1

# ---------- Startup ----------
COPY start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

# ---------- Defaults ----------
ENV WEBUI_ARGS="--listen --port ${PORT} --api --data-dir ${DATA_DIR} --enable-insecure-extension-access --xformers" \
    ENABLE_JUPYTER=1 \
    JUPYTER_TOKEN= \
    JUPYTER_PORT=8888

EXPOSE 7860 8888
CMD ["/opt/start.sh"]
