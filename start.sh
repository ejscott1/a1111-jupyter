#!/usr/bin/env bash
set -euo pipefail

# ---------- Config ----------
export WEBUI_DIR="${WEBUI_DIR:-/opt/webui}"
export DATA_DIR="${DATA_DIR:-/workspace/a1111-data}"
export PORT="${PORT:-7860}"
export WEBUI_ARGS="${WEBUI_ARGS:-"--listen --port ${PORT} --api --data-dir ${DATA_DIR} --enable-insecure-extension-access"}"

# Jupyter
export ENABLE_JUPYTER="${ENABLE_JUPYTER:-1}"
export JUPYTER_PORT="${JUPYTER_PORT:-8888}"
export JUPYTER_TOKEN="${JUPYTER_TOKEN:-}"  # set a token in ENV for security

# A1111 update/commit pin
export WEBUI_COMMIT="${WEBUI_COMMIT:-}"
export SKIP_GIT_UPDATE="${SKIP_GIT_UPDATE:-0}"

SD15_YAML_NAME="v1-inference.yaml"
SD15_YAML_URL="${SD15_YAML_URL:-https://raw.githubusercontent.com/CompVis/stable-diffusion/main/configs/stable-diffusion/${SD15_YAML_NAME}}"

# ---------- Persistent dirs ----------
mkdir -p \
  "${DATA_DIR}/models/Stable-diffusion" \
  "${DATA_DIR}/models/Lora" \
  "${DATA_DIR}/models/VAE" \
  "${DATA_DIR}/outputs" \
  "${DATA_DIR}/embeddings" \
  "${DATA_DIR}/configs" \
  "${DATA_DIR}/cache" \
  "${DATA_DIR}/logs"

# ---------- Clone/update A1111 ----------
if [ -d "${WEBUI_DIR}/.git" ]; then
  if [ "${SKIP_GIT_UPDATE}" != "1" ]; then
    echo "[A1111] Updating repo..."
    git -C "${WEBUI_DIR}" fetch --depth=1 origin
    git -C "${WEBUI_DIR}" reset --hard origin/master
  else
    echo "[A1111] Skipping git update (SKIP_GIT_UPDATE=1)"
  fi
else
  echo "[A1111] Fresh clone..."
  rm -rf "${WEBUI_DIR}" || true
  git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "${WEBUI_DIR}"
fi

# Optional commit pin
if [ -n "${WEBUI_COMMIT}" ]; then
  echo "[A1111] Pin commit ${WEBUI_COMMIT}"
  git -C "${WEBUI_DIR}" fetch --depth=1 origin "${WEBUI_COMMIT}" || true
  git -C "${WEBUI_DIR}" reset --hard "${WEBUI_COMMIT}"
fi

# ---------- Deps ----------
echo "[Deps] Installing requirements..."
pip install -r "${WEBUI_DIR}/requirements_versions.txt" || pip install -r "${WEBUI_DIR}/requirements.txt"

# Link embeddings/configs to persistent
for d in embeddings configs; do
  [ -e "${WEBUI_DIR}/${d}" ] && rm -rf "${WEBUI_DIR:?}/${d}"
  ln -s "${DATA_DIR}/${d}" "${WEBUI_DIR}/${d}"
done

# ---------- SD1.5 YAML ----------
if [ ! -f "${DATA_DIR}/configs/${SD15_YAML_NAME}" ]; then
  echo "[SD1.5] Fetching ${SD15_YAML_NAME}..."
  (curl -fsSL "${SD15_YAML_URL}" -o "${DATA_DIR}/configs/${SD15_YAML_NAME}" || \
   wget -q -O "${DATA_DIR}/configs/${SD15_YAML_NAME}" "${SD15_YAML_URL}" || true)
fi
mkdir -p "${WEBUI_DIR}/configs"
[ -s "${DATA_DIR}/configs/${SD15_YAML_NAME}" ] && cp -f "${DATA_DIR}/configs/${SD15_YAML_NAME}" "${WEBUI_DIR}/configs/${SD15_YAML_NAME}" || true

# ---------- JupyterLab (optional) ----------
if [ "${ENABLE_JUPYTER}" = "1" ]; then
  echo "[Jupyter] Starting on 0.0.0.0:${JUPYTER_PORT} (token: ${JUPYTER_TOKEN:-<none>})"
  nohup jupyter lab \
    --NotebookApp.notebook_dir="${DATA_DIR}" \
    --ServerApp.root_dir="${DATA_DIR}" \
    --ServerApp.allow_origin="*" \
    --ServerApp.ip=0.0.0.0 \
    --ServerApp.port="${JUPYTER_PORT}" \
    --ServerApp.open_browser=False \
    --ServerApp.token="${JUPYTER_TOKEN}" \
    > "${DATA_DIR}/logs/jupyter.log" 2>&1 &
fi

# ---------- Summary ----------
cat <<EOF
[Paths]
 - Data dir: ${DATA_DIR}
 - Checkpoints: ${DATA_DIR}/models/Stable-diffusion
 - Outputs: ${DATA_DIR}/outputs
 - Jupyter: $( [ "${ENABLE_JUPYTER}" = "1" ] && echo "http://<pod-host>:${JUPYTER_PORT} (token: ${JUPYTER_TOKEN:-<none>})" || echo "disabled" )

[Launch]
 python launch.py ${WEBUI_ARGS}
EOF

# ---------- Launch A1111 ----------
cd "${WEBUI_DIR}"
exec python launch.py ${WEBUI_ARGS}
