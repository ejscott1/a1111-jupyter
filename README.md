# A1111 + Jupyter (RunPod)

Variant of the minimal A1111 base image, with **JupyterLab** baked in for file browsing and a terminal.

## 🚀 Quick Start (RunPod Pod Settings)
Image: ghcr.io/ejscott1/a1111-jupyter:latest  
GPU: A4500/A5000 (balanced) or A40/4090 (fastest)  
Persistent Volume: mount at /workspace (50–100GB recommended)  
Expose Ports: 7860 (A1111), 8888 (Jupyter)  
Env (no auth):  
WEBUI_ARGS=--listen --port 7860 --api --data-dir /workspace/a1111-data --enable-insecure-extension-access  
ENABLE_JUPYTER=1  
JUPYTER_PORT=8888  
JUPYTER_TOKEN=  

## ✨ Features
- Pulls the latest A1111 code on each boot (optional pin to commit)  
- All models, outputs, and configs saved to persistent storage (/workspace/a1111-data)  
- Auto-downloads v1-inference.yaml for SD 1.5 models  
- Ready for both SD 1.5 and SDXL checkpoints  
- WebUI served on port 7860 with API enabled  
- JupyterLab served on port 8888 for file management and terminal access  

## 🛠 First Steps After Launch
1. Connect → HTTP 7860 for A1111, HTTP 8888 for Jupyter (token empty = no password).  
2. Upload at least one checkpoint to:  
   /workspace/a1111-data/models/Stable-diffusion/  
3. In A1111 → Settings → Reload UI → select your model.  

## 📂 Paths (inside Pod)
- Checkpoints: /workspace/a1111-data/models/Stable-diffusion/  
- LoRA: /workspace/a1111-data/models/Lora/  
- VAE: /workspace/a1111-data/models/VAE/  
- Outputs: /workspace/a1111-data/outputs/  
- Configs (SD1.5): /workspace/a1111-data/configs/v1-inference.yaml  

## 📝 Notes
- SD 1.5 needs v1-inference.yaml (auto-downloaded on first boot).  
- SDXL models don’t need a config file.  
- Outputs are persistent as long as your Pod uses the same volume.  
- If you want to password-protect Jupyter, set JUPYTER_TOKEN in env.  

## 📦 Source
This template is built from [a1111-jupyter](https://github.com/ejscott1/a1111-jupyter) and published to GHCR as:  
ghcr.io/ejscott1/a1111-jupyter:latest
