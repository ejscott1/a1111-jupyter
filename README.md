# A1111 + Jupyter (RunPod + GHCR)

Image that runs AUTOMATIC1111 Stable Diffusion WebUI with **JupyterLab** baked in for file browsing and a terminal.  
Optimized with **xFormers** for faster / lower-VRAM attention.  
Includes an **auto symlink repair** step so all models, outputs, configs, and embeddings persist in `/workspace/a1111-data`.

## 📦 Image
ghcr.io/ejscott1/a1111-jupyter:latest

## 🚀 Quick Start (RunPod)
- **Image:** ghcr.io/ejscott1/a1111-jupyter:latest  
- **GPU:** A4500 / A5000 (balanced) or A40 / RTX 4090 (fastest for SDXL)  
- **Persistent Volume:** mount at `/workspace` (50–100GB recommended)  
- **Expose Ports:** 7860 (A1111), 8888 (Jupyter)  
- **Environment Variables:**  
  ```
  WEBUI_ARGS=--listen --port 7860 --api --data-dir /workspace/a1111-data --enable-insecure-extension-access --xformers
  ENABLE_JUPYTER=1
  JUPYTER_PORT=8888
  ```

➡️ After launch:  
- **HTTP 8888** → JupyterLab (opens directly).  
- **HTTP 7860** → A1111 WebUI (`--xformers` enabled).  
- Upload checkpoints into `/workspace/a1111-data/models/Stable-diffusion/`.  

## 📂 Paths
- **Checkpoints:** `/workspace/a1111-data/models/Stable-diffusion/`  
- **LoRA:** `/workspace/a1111-data/models/Lora/`  
- **VAE:** `/workspace/a1111-data/models/VAE/`  
- **Outputs:** `/workspace/a1111-data/outputs/`  
- **Configs (SD 1.5):** `/workspace/a1111-data/configs/v1-inference.yaml`  
- **Jupyter root:** `/workspace` (so you can see `a1111-data`)  

## 📝 Notes
- CUDA 12.1 with Torch + xFormers (cu121 wheels).  
- Jupyter runs without a token by default (HTTP 8888 opens directly).  
- Auto symlink repair ensures all A1111 paths point to persistent storage.  

## 👩‍💻 Developer Notes
- Set `JUPYTER_ROOT=/workspace/a1111-data` if you want Jupyter to open directly inside the data folder.  
- You can set `JUPYTER_TOKEN` to enforce a login token instead of open access.
