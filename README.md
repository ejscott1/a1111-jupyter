# A1111 + Jupyter (RunPod + GHCR)

Variant of the minimal A1111 base image, with **JupyterLab** baked in for file browsing and a terminal.  
Optimized with **xFormers** for faster / lower-VRAM attention.  
Includes an **auto symlink repair** step so all models, outputs, configs, and embeddings always point into persistent storage (`/workspace/a1111-data`).

## 📦 Image
ghcr.io/ejscott1/a1111-jupyter:latest

## 🚀 Quick Start (RunPod)
- **Image:** ghcr.io/ejscott1/a1111-jupyter:latest  
- **GPU:** A4500 / A5000 (balanced) or A40 / RTX 4090 (fastest for SDXL)  
- **Persistent Volume:** mount at `/workspace` (50–100GB recommended)  
- **Expose Ports:** 7860 (A1111), 8888 (Jupyter)  
- **Environment Variables:**  
  WEBUI_ARGS=--listen --port 7860 --api --data-dir /workspace/a1111-data --enable-insecure-extension-access --xformers  
  ENABLE_JUPYTER=1  
  JUPYTER_PORT=8888  

➡️ After launch:  
1. Click **HTTP 7860** → Stable Diffusion WebUI.  
2. Click **HTTP 8888** → JupyterLab (opens directly, no login required).  
3. Upload at least one checkpoint into: `/workspace/a1111-data/models/Stable-diffusion/`  
4. In A1111 → Settings → Reload UI → select your model.  

## 📂 Paths
- **Checkpoints:** `/workspace/a1111-data/models/Stable-diffusion/`  
- **LoRA:** `/workspace/a1111-data/models/Lora/`  
- **VAE:** `/workspace/a1111-data/models/VAE/`  
- **Outputs:** `/workspace/a1111-data/outputs/`  
- **Configs (SD 1.5):** `/workspace/a1111-data/configs/v1-inference.yaml`  
- **Configs (A1111 runtime):** `/opt/webui/configs/v1-inference.yaml` (auto-synced)  
- **Jupyter root:** defaults to `/workspace` (so you can see `a1111-data` folder directly)  

## 🛠 Features
- Always pulls the latest A1111 code at boot (or pin with `WEBUI_COMMIT`).  
- Auto-downloads `v1-inference.yaml` for SD 1.5 models.  
- Full support for SD 1.5 and SDXL checkpoints.  
- **xFormers enabled by default** for better VRAM use & speed.  
- **Auto symlink fix** at boot → all `/opt/webui/*` paths are linked into `/workspace/a1111-data/*`.  
- Jupyter runs in an **isolated venv** at `/opt/jvenv`.  
- **No token by default** → clicking HTTP 8888 in RunPod opens Jupyter directly.  

## ⚙️ Environment Variables
- `WEBUI_DIR` (default `/opt/webui`)  
- `DATA_DIR` (default `/workspace/a1111-data`)  
- `PORT` (default `7860`)  
- `WEBUI_ARGS` (default includes extension access + xFormers)  
- `WEBUI_COMMIT` — pin A1111 to a specific commit SHA (optional)  
- `SKIP_GIT_UPDATE=1` — skip pulling latest A1111 on boot  
- `ENABLE_JUPYTER=1` — enable Jupyter (default on in this image)  
- `JUPYTER_PORT` (default `8888`)  
- `JUPYTER_TOKEN` — empty = no token (open access)  
- `JUPYTER_ROOT` — root dir for Jupyter (default `/workspace`)  

## 📝 Notes
- SD 1.5 checkpoints require `v1-inference.yaml` (auto-fetched on first boot).  
- SDXL checkpoints do **not** need a YAML.  
- Outputs, models, configs are safe as long as the same persistent volume is attached.  
- JupyterLab is wide open by default (`--ServerApp.token=''`). Only use on pods you control.  
- Optional extras (e.g., `realesrgan`, `gfpgan`, `basicsr`) can be preinstalled in the Dockerfile if you want built-in upscalers/face-restorers.
