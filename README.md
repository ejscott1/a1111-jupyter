# A1111 + Jupyter (RunPod)

Variant of the minimal A1111 base image, with **JupyterLab** baked in for file browsing and a terminal.

## Image
ghcr.io/ejscott1/a1111-jupyter:latest

## 🚀 Quick Start (RunPod)
- Image: ghcr.io/ejscott1/a1111-jupyter:latest
- GPU: A4500/A5000 (balanced) or A40/4090 (fastest)
- Persistent Volume: mount at /workspace (50–100GB recommended)
- Expose Ports: 7860 (A1111), 8888 (Jupyter)
- Environment Variables:
  WEBUI_ARGS=--listen --port 7860 --api --data-dir /workspace/a1111-data --enable-insecure-extension-access
  ENABLE_JUPYTER=1
  JUPYTER_PORT=8888

## First Steps
1. Connect → **HTTP 7860** for A1111, **HTTP 8888** for Jupyter (opens directly, no login page).
2. Upload at least one checkpoint to:
   /workspace/a1111-data/models/Stable-diffusion/
3. In A1111 → Settings → Reload UI → select your model.

## Notes
- SD 1.5 needs v1-inference.yaml (auto-downloaded on first boot).
- SDXL needs no YAML.
- Jupyter root is /workspace/a1111-data.
- ⚠️ Jupyter is wide open (no token). Only use with pods you control and shut them down when not in use.
